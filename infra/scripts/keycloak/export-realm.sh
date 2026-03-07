#!/usr/bin/env bash
###############################################################################
# keycloak/export-realm.sh
# Export a Keycloak realm configuration via the Admin REST API.
#
# Usage:
#   ./export-realm.sh --realm <realm-name> [--output <file>] [--include-users]
#   ./export-realm.sh --realm master --output /tmp/master-realm.json
#
# Environment:
#   KC_BASE_URL         -- Keycloak base URL (default: http://localhost:8080)
#   KC_ADMIN_USER       -- Admin username (default: admin)
#   KC_ADMIN_PASSWORD   -- Admin password (required)
#   IAM_ENV             -- Target environment (default: dev)
#
# Exit codes:
#   0 -- Success
#   1 -- Error (API failure, invalid response)
#   2 -- Misconfiguration (missing env vars)
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
OUTPUT_FILE=""
INCLUDE_USERS="false"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --realm)      REALM="$2"; shift 2 ;;
        --output)     OUTPUT_FILE="$2"; shift 2 ;;
        --include-users) INCLUDE_USERS="true"; shift ;;
        --help|-h)
            echo "Usage: $0 --realm <name> [--output <file>] [--include-users]"
            exit 0
            ;;
        *)
            log_error "Unknown argument: $1"
            exit 2
            ;;
    esac
done

if [[ -z "${REALM}" ]]; then
    log_error "Missing required argument: --realm <name>"
    echo "Usage: $0 --realm <name> [--output <file>] [--include-users]"
    exit 2
fi

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
require_commands curl jq
load_config
validate_config

# Default output file includes realm name and timestamp
if [[ -z "${OUTPUT_FILE}" ]]; then
    TIMESTAMP=$(date -u '+%Y%m%dT%H%M%SZ')
    OUTPUT_DIR="${BACKUP_DIR}/realms"
    mkdir -p "${OUTPUT_DIR}"
    OUTPUT_FILE="${OUTPUT_DIR}/${REALM}-${TIMESTAMP}.json"
fi

# Ensure output directory exists
mkdir -p "$(dirname "${OUTPUT_FILE}")"

# ---------------------------------------------------------------------------
# Obtain admin token
# ---------------------------------------------------------------------------
require_kc_admin_token

# ---------------------------------------------------------------------------
# Export realm
# ---------------------------------------------------------------------------
log_section "Realm Export"
log_kv "Realm" "${REALM}"
log_kv "Include Users" "${INCLUDE_USERS}"
log_kv "Output File" "${OUTPUT_FILE}"

log_info "Exporting realm '${REALM}' from ${KC_BASE_URL}..."

# Build the partial-export URL with query parameters
EXPORT_URL="${KC_BASE_URL}/admin/realms/${REALM}/partial-export"
EXPORT_URL="${EXPORT_URL}?exportClients=true&exportGroupsAndRoles=true"

HTTP_CODE=$(curl --silent --output "${OUTPUT_FILE}" --write-out "%{http_code}" \
    -X POST "${EXPORT_URL}" \
    -H "Authorization: Bearer ${KC_ADMIN_TOKEN}" \
    -H "Content-Type: application/json")

if [[ "${HTTP_CODE}" -ne 200 ]]; then
    log_error "Realm export failed with HTTP ${HTTP_CODE}."
    if [[ -f "${OUTPUT_FILE}" ]]; then
        log_error "Response body: $(cat "${OUTPUT_FILE}")"
        rm -f "${OUTPUT_FILE}"
    fi
    exit 1
fi

# Validate the exported JSON
if ! jq empty "${OUTPUT_FILE}" 2>/dev/null; then
    log_error "Exported file is not valid JSON: ${OUTPUT_FILE}"
    exit 1
fi

# Print summary
REALM_ID=$(jq -r '.id // "unknown"' "${OUTPUT_FILE}")
CLIENT_COUNT=$(jq -r '.clients | length // 0' "${OUTPUT_FILE}")
ROLE_COUNT=$(jq -r '.roles.realm | length // 0' "${OUTPUT_FILE}")
FILE_SIZE=$(du -h "${OUTPUT_FILE}" | cut -f1)

log_section "Export Summary"
log_kv "Realm ID" "${REALM_ID}"
log_kv "Clients" "${CLIENT_COUNT}"
log_kv "Realm Roles" "${ROLE_COUNT}"
log_kv "File Size" "${FILE_SIZE}"
log_kv "Output" "${OUTPUT_FILE}"

log_success "Realm '${REALM}' exported successfully to ${OUTPUT_FILE}"
