#!/usr/bin/env bash
###############################################################################
# operations/rotate-secrets.sh
# Rotate Kubernetes secrets for the IAM platform.
#
# Generates new secret values and updates the specified Kubernetes secret.
# Supports rotating database passwords, Keycloak admin credentials, and
# client secrets. Optionally triggers a rolling restart of affected pods.
#
# Usage:
#   ./rotate-secrets.sh --secret <name> --namespace <ns> --key <key> \
#       [--value <new-value>] [--restart] [--dry-run] [--force]
#   ./rotate-secrets.sh --secret keycloak-db-credentials --namespace iam \
#       --key POSTGRES_PASSWORD --restart
#
# Environment:
#   KUBECONFIG          -- Path to kubeconfig (optional)
#   IAM_ENV             -- Target environment (default: dev)
#
# Exit codes:
#   0 -- Success
#   1 -- Error
#   2 -- Misconfiguration
#   3 -- Dependency failure
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common/logging.sh"
source "${SCRIPT_DIR}/../common/preconditions.sh"
source "${SCRIPT_DIR}/../common/config.sh"

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
SECRET_NAME=""
NAMESPACE=""
SECRET_KEY=""
NEW_VALUE=""
RESTART_PODS="false"
DRY_RUN="false"
FORCE="false"
DEPLOYMENT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --secret)     SECRET_NAME="$2"; shift 2 ;;
        --namespace)  NAMESPACE="$2"; shift 2 ;;
        --key)        SECRET_KEY="$2"; shift 2 ;;
        --value)      NEW_VALUE="$2"; shift 2 ;;
        --deployment) DEPLOYMENT="$2"; shift 2 ;;
        --restart)    RESTART_PODS="true"; shift ;;
        --dry-run)    DRY_RUN="true"; shift ;;
        --force)      FORCE="true"; shift ;;
        --help|-h)
            echo "Usage: $0 --secret <name> --namespace <ns> --key <key>"
            echo "       [--value <new-value>] [--deployment <name>]"
            echo "       [--restart] [--dry-run] [--force]"
            exit 0
            ;;
        *)
            log_error "Unknown argument: $1"
            exit 2
            ;;
    esac
done

# Validate required arguments
if [[ -z "${SECRET_NAME}" || -z "${NAMESPACE}" || -z "${SECRET_KEY}" ]]; then
    log_error "Missing required arguments: --secret, --namespace, and --key are mandatory."
    exit 2
fi

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
require_commands kubectl openssl
load_config

# Generate a new random value if none provided
if [[ -z "${NEW_VALUE}" ]]; then
    NEW_VALUE=$(openssl rand -base64 32 | tr -d '=+/' | head -c 32)
    log_info "Generated new random secret value (32 characters)."
fi

# ---------------------------------------------------------------------------
# Display plan
# ---------------------------------------------------------------------------
log_section "Secret Rotation"
log_kv "Secret" "${SECRET_NAME}"
log_kv "Namespace" "${NAMESPACE}"
log_kv "Key" "${SECRET_KEY}"
log_kv "New Value" "********"
log_kv "Restart Pods" "${RESTART_PODS}"
log_kv "Deployment" "${DEPLOYMENT:-<auto-detect>}"
log_kv "Environment" "${IAM_ENV}"

# ---------------------------------------------------------------------------
# Verify secret exists
# ---------------------------------------------------------------------------
log_info "Verifying secret '${SECRET_NAME}' exists in namespace '${NAMESPACE}'..."
if ! kubectl get secret "${SECRET_NAME}" -n "${NAMESPACE}" &>/dev/null; then
    log_error "Secret '${SECRET_NAME}' not found in namespace '${NAMESPACE}'."
    exit 1
fi

# Verify the key exists in the secret
EXISTING_KEYS=$(kubectl get secret "${SECRET_NAME}" -n "${NAMESPACE}" \
    -o jsonpath='{.data}' | jq -r 'keys[]' 2>/dev/null || echo "")
if [[ -n "${EXISTING_KEYS}" ]] && ! echo "${EXISTING_KEYS}" | grep -q "^${SECRET_KEY}$"; then
    log_warn "Key '${SECRET_KEY}' does not currently exist in secret '${SECRET_NAME}'. It will be added."
fi

log_success "Secret '${SECRET_NAME}' found."

if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "Dry-run mode: no changes will be made."
    log_info "Would update key '${SECRET_KEY}' in secret '${SECRET_NAME}' (namespace: ${NAMESPACE})."
    if [[ "${RESTART_PODS}" == "true" ]]; then
        log_info "Would trigger rolling restart of related deployments."
    fi
    log_success "Dry-run validation complete."
    exit 0
fi

# ---------------------------------------------------------------------------
# Confirm destructive operation
# ---------------------------------------------------------------------------
confirm_action "Rotate key '${SECRET_KEY}' in secret '${SECRET_NAME}' (${NAMESPACE})" || exit 0

# ---------------------------------------------------------------------------
# Update the secret
# ---------------------------------------------------------------------------
log_info "Updating secret '${SECRET_NAME}'..."

# Encode the new value in base64
ENCODED_VALUE=$(echo -n "${NEW_VALUE}" | base64)

# Patch the secret with the new key-value pair
kubectl patch secret "${SECRET_NAME}" -n "${NAMESPACE}" \
    --type='json' \
    -p="[{\"op\": \"replace\", \"path\": \"/data/${SECRET_KEY}\", \"value\": \"${ENCODED_VALUE}\"}]" \
    || {
        # If replace fails (key does not exist), try add
        kubectl patch secret "${SECRET_NAME}" -n "${NAMESPACE}" \
            --type='json' \
            -p="[{\"op\": \"add\", \"path\": \"/data/${SECRET_KEY}\", \"value\": \"${ENCODED_VALUE}\"}]"
    }

log_success "Secret '${SECRET_NAME}' updated with new value for key '${SECRET_KEY}'."

# ---------------------------------------------------------------------------
# Add rotation timestamp annotation
# ---------------------------------------------------------------------------
ROTATION_TS=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
kubectl annotate secret "${SECRET_NAME}" -n "${NAMESPACE}" \
    "iam.ximplicity.com/last-rotated=${ROTATION_TS}" \
    "iam.ximplicity.com/rotated-key=${SECRET_KEY}" \
    --overwrite

# ---------------------------------------------------------------------------
# Trigger rolling restart if requested
# ---------------------------------------------------------------------------
if [[ "${RESTART_PODS}" == "true" ]]; then
    if [[ -n "${DEPLOYMENT}" ]]; then
        DEPLOYMENTS=("${DEPLOYMENT}")
    else
        # Auto-detect deployments that reference this secret
        log_info "Auto-detecting deployments that reference secret '${SECRET_NAME}'..."
        mapfile -t DEPLOYMENTS < <(
            kubectl get deployments -n "${NAMESPACE}" -o json \
                | jq -r --arg secret "${SECRET_NAME}" \
                    '.items[] | select(.spec.template.spec.volumes[]?.secret.secretName == $secret or (.spec.template.spec.containers[]?.envFrom[]?.secretRef.name == $secret)) | .metadata.name' \
                2>/dev/null || true
        )
    fi

    if [[ ${#DEPLOYMENTS[@]} -eq 0 ]]; then
        log_warn "No deployments found referencing secret '${SECRET_NAME}'. Skipping restart."
    else
        for deploy in "${DEPLOYMENTS[@]}"; do
            log_info "Restarting deployment: ${deploy}..."
            kubectl rollout restart deployment/"${deploy}" -n "${NAMESPACE}"
            log_success "Rolling restart initiated for deployment '${deploy}'."
        done
    fi
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
log_section "Rotation Summary"
log_kv "Secret" "${SECRET_NAME}"
log_kv "Key" "${SECRET_KEY}"
log_kv "Namespace" "${NAMESPACE}"
log_kv "Rotated At" "${ROTATION_TS}"
log_kv "Pods Restarted" "${RESTART_PODS}"

log_success "Secret rotation completed successfully."
