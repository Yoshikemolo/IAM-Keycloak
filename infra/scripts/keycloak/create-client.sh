#!/usr/bin/env bash
###############################################################################
# keycloak/create-client.sh
# Register an OIDC client in Keycloak via the Admin REST API.
#
# Usage:
#   ./create-client.sh --realm <realm> --client-id <id> \
#       --redirect-uris "https://app.example.com/*" \
#       [--client-secret <secret>] [--public] [--dry-run] [--force]
#
# Environment:
#   KC_BASE_URL         -- Keycloak base URL (default: http://localhost:8080)
#   KC_ADMIN_USER       -- Admin username (default: admin)
#   KC_ADMIN_PASSWORD   -- Admin password (required)
#
# Exit codes:
#   0 -- Success
#   1 -- Error (API failure)
#   2 -- Misconfiguration (missing args)
#   3 -- Dependency failure (missing tools)
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common/logging.sh"
source "${SCRIPT_DIR}/../common/preconditions.sh"
source "${SCRIPT_DIR}/../common/config.sh"

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
REALM=""
CLIENT_ID=""
CLIENT_SECRET=""
REDIRECT_URIS=""
PUBLIC_CLIENT="false"
DRY_RUN="false"
FORCE="false"
CLIENT_NAME=""
ROOT_URL=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --realm)          REALM="$2"; shift 2 ;;
        --client-id)      CLIENT_ID="$2"; shift 2 ;;
        --client-name)    CLIENT_NAME="$2"; shift 2 ;;
        --client-secret)  CLIENT_SECRET="$2"; shift 2 ;;
        --redirect-uris)  REDIRECT_URIS="$2"; shift 2 ;;
        --root-url)       ROOT_URL="$2"; shift 2 ;;
        --public)         PUBLIC_CLIENT="true"; shift ;;
        --dry-run)        DRY_RUN="true"; shift ;;
        --force)          FORCE="true"; shift ;;
        --help|-h)
            echo "Usage: $0 --realm <realm> --client-id <id> --redirect-uris <uris>"
            echo "       [--client-secret <secret>] [--client-name <name>]"
            echo "       [--root-url <url>] [--public] [--dry-run] [--force]"
            exit 0
            ;;
        *)
            log_error "Unknown argument: $1"
            exit 2
            ;;
    esac
done

# Validate required arguments
if [[ -z "${REALM}" || -z "${CLIENT_ID}" ]]; then
    log_error "Missing required arguments: --realm and --client-id are mandatory."
    echo "Usage: $0 --realm <realm> --client-id <id> --redirect-uris <uris>"
    exit 2
fi

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
require_commands curl jq
load_config
validate_config

# Default client name to client ID if not specified
CLIENT_NAME="${CLIENT_NAME:-${CLIENT_ID}}"

# Generate a client secret if not public and none provided
if [[ "${PUBLIC_CLIENT}" == "false" && -z "${CLIENT_SECRET}" ]]; then
    CLIENT_SECRET=$(openssl rand -base64 32)
    log_info "Generated random client secret (will be displayed at the end)."
fi

# Parse redirect URIs (comma-separated) into JSON array
REDIRECT_JSON="[]"
if [[ -n "${REDIRECT_URIS}" ]]; then
    REDIRECT_JSON=$(echo "${REDIRECT_URIS}" | tr ',' '\n' | jq -R . | jq -s .)
fi

# ---------------------------------------------------------------------------
# Build client JSON payload
# ---------------------------------------------------------------------------
CLIENT_JSON=$(jq -n \
    --arg clientId "${CLIENT_ID}" \
    --arg name "${CLIENT_NAME}" \
    --arg rootUrl "${ROOT_URL}" \
    --argjson publicClient "${PUBLIC_CLIENT}" \
    --argjson redirectUris "${REDIRECT_JSON}" \
    --arg secret "${CLIENT_SECRET}" \
    '{
        clientId: $clientId,
        name: $name,
        enabled: true,
        protocol: "openid-connect",
        publicClient: $publicClient,
        standardFlowEnabled: true,
        directAccessGrantsEnabled: true,
        serviceAccountsEnabled: (if $publicClient then false else true end),
        authorizationServicesEnabled: false,
        redirectUris: $redirectUris,
        webOrigins: ["+"],
        attributes: {
            "post.logout.redirect.uris": "+",
            "oauth2.device.authorization.grant.enabled": "false",
            "backchannel.logout.session.required": "true",
            "backchannel.logout.revoke.offline.tokens": "false"
        }
    }
    | if $rootUrl != "" then .rootUrl = $rootUrl else . end
    | if $publicClient == false then .secret = $secret else . end
    ')

# ---------------------------------------------------------------------------
# Display plan
# ---------------------------------------------------------------------------
log_section "OIDC Client Registration"
log_kv "Realm" "${REALM}"
log_kv "Client ID" "${CLIENT_ID}"
log_kv "Client Name" "${CLIENT_NAME}"
log_kv "Public Client" "${PUBLIC_CLIENT}"
log_kv "Redirect URIs" "${REDIRECT_URIS:-<none>}"
log_kv "Root URL" "${ROOT_URL:-<none>}"
log_kv "Target" "${KC_BASE_URL}"

if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "Dry-run mode: Generated client JSON:"
    echo "${CLIENT_JSON}" | jq .
    log_success "Dry-run complete. No changes made."
    exit 0
fi

# ---------------------------------------------------------------------------
# Register the client
# ---------------------------------------------------------------------------
require_kc_admin_token

log_info "Registering client '${CLIENT_ID}' in realm '${REALM}'..."

HTTP_CODE=$(curl --silent --output /tmp/kc-client-response.json --write-out "%{http_code}" \
    -X POST "${KC_BASE_URL}/admin/realms/${REALM}/clients" \
    -H "Authorization: Bearer ${KC_ADMIN_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "${CLIENT_JSON}")

if [[ "${HTTP_CODE}" -eq 201 ]]; then
    log_success "Client '${CLIENT_ID}' registered successfully."
elif [[ "${HTTP_CODE}" -eq 409 ]]; then
    log_warn "Client '${CLIENT_ID}' already exists in realm '${REALM}'."
    if [[ "${FORCE}" == "true" ]]; then
        log_info "Updating existing client (--force)..."
        # Get the internal UUID of the existing client
        EXISTING_UUID=$(curl --silent \
            -H "Authorization: Bearer ${KC_ADMIN_TOKEN}" \
            "${KC_BASE_URL}/admin/realms/${REALM}/clients?clientId=${CLIENT_ID}" \
            | jq -r '.[0].id // empty')

        if [[ -z "${EXISTING_UUID}" ]]; then
            log_error "Could not find internal ID for existing client '${CLIENT_ID}'."
            exit 1
        fi

        HTTP_CODE=$(curl --silent --output /tmp/kc-client-response.json --write-out "%{http_code}" \
            -X PUT "${KC_BASE_URL}/admin/realms/${REALM}/clients/${EXISTING_UUID}" \
            -H "Authorization: Bearer ${KC_ADMIN_TOKEN}" \
            -H "Content-Type: application/json" \
            -d "${CLIENT_JSON}")

        if [[ "${HTTP_CODE}" -ne 204 && "${HTTP_CODE}" -ne 200 ]]; then
            log_error "Client update failed with HTTP ${HTTP_CODE}."
            cat /tmp/kc-client-response.json 2>/dev/null || true
            exit 1
        fi
        log_success "Client '${CLIENT_ID}' updated successfully."
    else
        log_error "Use --force to update the existing client."
        exit 1
    fi
else
    log_error "Client registration failed with HTTP ${HTTP_CODE}."
    cat /tmp/kc-client-response.json 2>/dev/null || true
    exit 1
fi

# ---------------------------------------------------------------------------
# Print client credentials
# ---------------------------------------------------------------------------
log_section "Client Credentials"
log_kv "Client ID" "${CLIENT_ID}"
if [[ "${PUBLIC_CLIENT}" == "false" ]]; then
    log_kv "Client Secret" "${CLIENT_SECRET}"
fi
log_kv "Token URL" "${KC_BASE_URL}/realms/${REALM}/protocol/openid-connect/token"
log_kv "Auth URL" "${KC_BASE_URL}/realms/${REALM}/protocol/openid-connect/auth"
log_kv "JWKS URL" "${KC_BASE_URL}/realms/${REALM}/protocol/openid-connect/certs"

# Clean up
rm -f /tmp/kc-client-response.json
