#!/usr/bin/env bash
###############################################################################
# operations/scale-cluster.sh
# Scale Keycloak deployment replicas in Kubernetes.
#
# Adjusts the replica count for the Keycloak deployment and monitors the
# rollout status. Includes safety checks for production environments and
# minimum/maximum replica boundaries.
#
# Usage:
#   ./scale-cluster.sh --replicas <count> [--namespace <ns>] \
#       [--deployment <name>] [--wait] [--dry-run] [--force]
#   ./scale-cluster.sh --replicas 3 --namespace iam --wait
#
# Environment:
#   KUBECONFIG          -- Path to kubeconfig (optional)
#   IAM_ENV             -- Target environment (default: dev)
#
# Exit codes:
#   0 -- Success
#   1 -- Error (scaling or rollout failure)
#   2 -- Misconfiguration
#   3 -- Dependency failure
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common/logging.sh"
source "${SCRIPT_DIR}/../common/preconditions.sh"
source "${SCRIPT_DIR}/../common/config.sh"

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
MIN_REPLICAS=1
MAX_REPLICAS=10
DEFAULT_DEPLOYMENT="keycloak"
DEFAULT_NAMESPACE="iam"
ROLLOUT_TIMEOUT="300s"

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
REPLICAS=""
NAMESPACE="${DEFAULT_NAMESPACE}"
DEPLOYMENT="${DEFAULT_DEPLOYMENT}"
WAIT_ROLLOUT="false"
DRY_RUN="false"
FORCE="false"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --replicas)    REPLICAS="$2"; shift 2 ;;
        --namespace)   NAMESPACE="$2"; shift 2 ;;
        --deployment)  DEPLOYMENT="$2"; shift 2 ;;
        --wait)        WAIT_ROLLOUT="true"; shift ;;
        --dry-run)     DRY_RUN="true"; shift ;;
        --force)       FORCE="true"; shift ;;
        --timeout)     ROLLOUT_TIMEOUT="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: $0 --replicas <count> [--namespace <ns>] [--deployment <name>]"
            echo "       [--wait] [--timeout <duration>] [--dry-run] [--force]"
            exit 0
            ;;
        *)
            log_error "Unknown argument: $1"
            exit 2
            ;;
    esac
done

if [[ -z "${REPLICAS}" ]]; then
    log_error "Missing required argument: --replicas <count>"
    exit 2
fi

# Validate replica count is numeric
if [[ ! "${REPLICAS}" =~ ^[0-9]+$ ]]; then
    log_error "Replica count must be a positive integer. Got: ${REPLICAS}"
    exit 2
fi

# Validate boundaries
if [[ "${REPLICAS}" -lt "${MIN_REPLICAS}" || "${REPLICAS}" -gt "${MAX_REPLICAS}" ]]; then
    log_error "Replica count must be between ${MIN_REPLICAS} and ${MAX_REPLICAS}. Got: ${REPLICAS}"
    if [[ "${FORCE}" != "true" ]]; then
        exit 2
    fi
    log_warn "Proceeding despite boundary violation (--force)."
fi

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
require_commands kubectl
load_config

# ---------------------------------------------------------------------------
# Get current state
# ---------------------------------------------------------------------------
log_info "Fetching current deployment state..."

if ! kubectl get deployment "${DEPLOYMENT}" -n "${NAMESPACE}" &>/dev/null; then
    log_error "Deployment '${DEPLOYMENT}' not found in namespace '${NAMESPACE}'."
    exit 1
fi

CURRENT_REPLICAS=$(kubectl get deployment "${DEPLOYMENT}" -n "${NAMESPACE}" \
    -o jsonpath='{.spec.replicas}')
READY_REPLICAS=$(kubectl get deployment "${DEPLOYMENT}" -n "${NAMESPACE}" \
    -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")

# ---------------------------------------------------------------------------
# Display plan
# ---------------------------------------------------------------------------
log_section "Cluster Scaling"
log_kv "Deployment" "${DEPLOYMENT}"
log_kv "Namespace" "${NAMESPACE}"
log_kv "Current Replicas" "${CURRENT_REPLICAS} (${READY_REPLICAS} ready)"
log_kv "Target Replicas" "${REPLICAS}"
log_kv "Wait for Rollout" "${WAIT_ROLLOUT}"
log_kv "Environment" "${IAM_ENV}"

# Check if scaling is necessary
if [[ "${CURRENT_REPLICAS}" -eq "${REPLICAS}" ]]; then
    log_info "Deployment already has ${REPLICAS} replica(s). No scaling needed."
    exit 0
fi

# Determine direction
if [[ "${REPLICAS}" -gt "${CURRENT_REPLICAS}" ]]; then
    SCALE_DIR="UP"
else
    SCALE_DIR="DOWN"
fi
log_kv "Direction" "Scale ${SCALE_DIR} (${CURRENT_REPLICAS} -> ${REPLICAS})"

if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "Dry-run mode: no changes will be made."
    log_success "Dry-run complete."
    exit 0
fi

# ---------------------------------------------------------------------------
# Safety check for production scale-down
# ---------------------------------------------------------------------------
if [[ "${IAM_ENV}" == "prod" && "${SCALE_DIR}" == "DOWN" ]]; then
    log_warn "Scaling DOWN in PRODUCTION environment."
    if [[ "${REPLICAS}" -lt 2 ]]; then
        log_warn "Scaling below 2 replicas in production removes high availability."
    fi
fi

confirm_action "Scale deployment '${DEPLOYMENT}' from ${CURRENT_REPLICAS} to ${REPLICAS} replicas (${IAM_ENV})" || exit 0

# ---------------------------------------------------------------------------
# Execute scaling
# ---------------------------------------------------------------------------
log_info "Scaling deployment '${DEPLOYMENT}' to ${REPLICAS} replicas..."

kubectl scale deployment "${DEPLOYMENT}" \
    -n "${NAMESPACE}" \
    --replicas="${REPLICAS}"

log_success "Scale command issued successfully."

# ---------------------------------------------------------------------------
# Wait for rollout (optional)
# ---------------------------------------------------------------------------
if [[ "${WAIT_ROLLOUT}" == "true" ]]; then
    log_info "Waiting for rollout to complete (timeout: ${ROLLOUT_TIMEOUT})..."

    if kubectl rollout status deployment/"${DEPLOYMENT}" \
        -n "${NAMESPACE}" \
        --timeout="${ROLLOUT_TIMEOUT}"; then
        log_success "Rollout completed successfully."
    else
        log_error "Rollout did not complete within ${ROLLOUT_TIMEOUT}."
        log_info "Current pod status:"
        kubectl get pods -n "${NAMESPACE}" -l "app=${DEPLOYMENT}" \
            --no-headers 2>/dev/null || true
        exit 1
    fi
fi

# ---------------------------------------------------------------------------
# Post-scaling status
# ---------------------------------------------------------------------------
log_info "Post-scaling status:"
kubectl get deployment "${DEPLOYMENT}" -n "${NAMESPACE}" -o wide
echo ""
kubectl get pods -n "${NAMESPACE}" -l "app=${DEPLOYMENT}" --no-headers 2>/dev/null \
    | while IFS= read -r line; do
        echo "  ${line}"
    done || true

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
NEW_READY=$(kubectl get deployment "${DEPLOYMENT}" -n "${NAMESPACE}" \
    -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "pending")

log_section "Scaling Summary"
log_kv "Deployment" "${DEPLOYMENT}"
log_kv "Previous Replicas" "${CURRENT_REPLICAS}"
log_kv "Target Replicas" "${REPLICAS}"
log_kv "Ready Replicas" "${NEW_READY}"

log_success "Cluster scaling completed."
