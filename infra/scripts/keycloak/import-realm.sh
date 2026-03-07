#!/usr/bin/env bash
###############################################################################
# keycloak/import-realm.sh
# Import a Keycloak realm configuration via the Admin REST API.
#
# Usage:
#   ./import-realm.sh --file <realm.json> [--overwrite] [--force] [--dry-run]
#   ./import-realm.sh --file /backups/master-realm.json --overwrite
#
# Environment:
#   KC_BASE_URL         -- Keycloak base URL (default: http://localhost:8080)
#   KC_ADMIN_USER       -- Admin username (default: admin)
#   KC_ADMIN_PASSWORD   -- Admin password (required)
#   IAM_ENV             -- Target environment (default: dev)
#
# Exit codes:
#   0 -- Success
#   1 -- Error (API failure)
#   2 -- Misconfiguration (missing args, invalid JSON)
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
INPUT_FILE=""
OVERWRITE="false"
FORCE="false"
DRY_RUN="false"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --file)       INPUT_FILE="$2"; shift 2 ;;
        --overwrite)  OVERWRITE="true"; shift ;;
        --force)      FORCE="true"; shift ;;
        --dry-run)    DRY_RUN="true"; shift ;;
        --help|-h)
            echo "Usage: $0 --file <realm.json> [--overwrite] [--force] [--dry-run]"
            exit 0
            ;;
        *)
            log_error "Unknown argument: $1"
            exit 2
            ;;
    esac
done

if [[ -z "${INPUT_FILE}" ]]; then
    log_error "Missing required argument: --file <realm.json>"
    echo "Usage: $0 --file <realm.json> [--overwrite] [--force] [--dry-run]"
    exit 2
fi

# ---------------------------------------------------------------------------
# Validate input
# ---------------------------------------------------------------------------
require_commands curl jq
require_file "${INPUT_FILE}"
load_config
validate_config

# Validate JSON structure
if ! jq empty "${INPUT_FILE}" 2>/dev/null; then
    log_error "Input file is not valid JSON: ${INPUT_FILE}"
    exit 2
fi

REALM_NAME=$(jq -r '.realm // .id // empty' "${INPUT_FILE}")
if [[ -z "${REALM_NAME}" ]]; then
    log_error "Cannot determine realm name from input file. Ensure the JSON contains a 'realm' or 'id' field."
    exit 2
fi

# ---------------------------------------------------------------------------
# Display import plan
# ---------------------------------------------------------------------------
log_section "Realm Import"
log_kv "Realm" "${REALM_NAME}"
log_kv "Input File" "${INPUT_FILE}"
log_kv "Overwrite" "${OVERWRITE}"
log_kv "Dry Run" "${DRY_RUN}"
log_kv "Target" "${KC_BASE_URL}"
log_kv "Environment" "${IAM_ENV}"

CLIENT_COUNT=$(jq -r '.clients | length // 0' "${INPUT_FILE}")
ROLE_COUNT=$(jq -r '.roles.realm | length // 0' "${INPUT_FILE}")
log_kv "Clients" "${CLIENT_COUNT}"
log_kv "Realm Roles" "${ROLE_COUNT}"

if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "Dry-run mode: no changes will be made."
    log_success "Dry-run validation complete. File is valid for import."
    exit 0
fi

# ---------------------------------------------------------------------------
# Confirm destructive operation
# ---------------------------------------------------------------------------
confirm_action "Import realm '${REALM_NAME}' into ${KC_BASE_URL} (${IAM_ENV})" || exit 0

# ---------------------------------------------------------------------------
# Obtain admin token
# ---------------------------------------------------------------------------
require_kc_admin_token

# ---------------------------------------------------------------------------
# Check if realm already exists
# ---------------------------------------------------------------------------
log_info "Checking if realm '${REALM_NAME}' already exists..."

EXISTING_HTTP_CODE=$(curl --silent --output /dev/null --write-out "%{http_code}" \
    -H "Authorization: Bearer ${KC_ADMIN_TOKEN}" \
    "${KC_BASE_URL}/admin/realms/${REALM_NAME}")

if [[ "${EXISTING_HTTP_CODE}" -eq 200 ]]; then
    if [[ "${OVERWRITE}" == "true" ]]; then
        log_warn "Realm '${REALM_NAME}' already exists. Overwriting with PUT request."

        HTTP_CODE=$(curl --silent --output /tmp/kc-import-response.json --write-out "%{http_code}" \
            -X PUT "${KC_BASE_URL}/admin/realms/${REALM_NAME}" \
            -H "Authorization: Bearer ${KC_ADMIN_TOKEN}" \
            -H "Content-Type: application/json" \
            -d @"${INPUT_FILE}")

        if [[ "${HTTP_CODE}" -ne 204 && "${HTTP_CODE}" -ne 200 ]]; then
            log_error "Realm update failed with HTTP ${HTTP_CODE}."
            cat /tmp/kc-import-response.json 2>/dev/null || true
            exit 1
        fi

        log_success "Realm '${REALM_NAME}' updated successfully."
    else
        log_error "Realm '${REALM_NAME}' already exists. Use --overwrite to replace it."
        exit 1
    fi
else
    # Realm does not exist -- create it
    log_info "Creating new realm '${REALM_NAME}'..."

    HTTP_CODE=$(curl --silent --output /tmp/kc-import-response.json --write-out "%{http_code}" \
        -X POST "${KC_BASE_URL}/admin/realms" \
        -H "Authorization: Bearer ${KC_ADMIN_TOKEN}" \
        -H "Content-Type: application/json" \
        -d @"${INPUT_FILE}")

    if [[ "${HTTP_CODE}" -ne 201 && "${HTTP_CODE}" -ne 200 ]]; then
        log_error "Realm creation failed with HTTP ${HTTP_CODE}."
        cat /tmp/kc-import-response.json 2>/dev/null || true
        exit 1
    fi

    log_success "Realm '${REALM_NAME}' created successfully."
fi

# Clean up temporary files
rm -f /tmp/kc-import-response.json

log_success "Realm import completed for '${REALM_NAME}' on ${KC_BASE_URL}"
