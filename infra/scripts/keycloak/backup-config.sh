#!/usr/bin/env bash
###############################################################################
# keycloak/backup-config.sh
# Full realm configuration backup via the Keycloak Admin REST API.
#
# Exports all realms (or a specified list) and packages them into a
# compressed, timestamped archive. Supports backup rotation.
#
# Usage:
#   ./backup-config.sh [--realms "master,app"] [--output-dir /backups] [--force]
#   ./backup-config.sh                         # Backs up all realms
#
# Environment:
#   KC_BASE_URL         -- Keycloak base URL (default: http://localhost:8080)
#   KC_ADMIN_USER       -- Admin username
#   KC_ADMIN_PASSWORD   -- Admin password
#   BACKUP_DIR          -- Backup storage directory
#   BACKUP_RETENTION_DAYS -- Days to keep old backups (default: 30)
#
# Exit codes:
#   0 -- Success
#   1 -- Error (export or compression failed)
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
REALM_LIST=""
OUTPUT_DIR=""
FORCE="false"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --realms)      REALM_LIST="$2"; shift 2 ;;
        --output-dir)  OUTPUT_DIR="$2"; shift 2 ;;
        --force)       FORCE="true"; shift ;;
        --help|-h)
            echo "Usage: $0 [--realms 'master,app'] [--output-dir /backups] [--force]"
            exit 0
            ;;
        *)
            log_error "Unknown argument: $1"
            exit 2
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
require_commands curl jq tar gzip
load_config
validate_config

TIMESTAMP=$(date -u '+%Y%m%dT%H%M%SZ')
OUTPUT_DIR="${OUTPUT_DIR:-${BACKUP_DIR}/config}"
WORK_DIR="${OUTPUT_DIR}/work-${TIMESTAMP}"
ARCHIVE_FILE="${OUTPUT_DIR}/kc-config-${IAM_ENV}-${TIMESTAMP}.tar.gz"

mkdir -p "${WORK_DIR}"

# ---------------------------------------------------------------------------
# Obtain admin token
# ---------------------------------------------------------------------------
require_kc_admin_token

# ---------------------------------------------------------------------------
# Discover realms if not specified
# ---------------------------------------------------------------------------
if [[ -z "${REALM_LIST}" ]]; then
    log_info "Discovering all realms from ${KC_BASE_URL}..."
    REALM_LIST=$(curl --silent --fail \
        -H "Authorization: Bearer ${KC_ADMIN_TOKEN}" \
        "${KC_BASE_URL}/admin/realms" \
        | jq -r '.[].realm' \
        | tr '\n' ',')
    REALM_LIST="${REALM_LIST%,}"  # Remove trailing comma
fi

if [[ -z "${REALM_LIST}" ]]; then
    log_error "No realms found or unable to list realms."
    exit 1
fi

log_section "Configuration Backup"
log_kv "Environment" "${IAM_ENV}"
log_kv "Realms" "${REALM_LIST}"
log_kv "Output Dir" "${OUTPUT_DIR}"
log_kv "Archive" "${ARCHIVE_FILE}"
log_kv "Timestamp" "${TIMESTAMP}"

# ---------------------------------------------------------------------------
# Export each realm
# ---------------------------------------------------------------------------
IFS=',' read -ra REALMS <<< "${REALM_LIST}"
EXPORTED=0
FAILED=0

for realm in "${REALMS[@]}"; do
    realm=$(echo "${realm}" | xargs)  # Trim whitespace
    log_info "Exporting realm: ${realm}..."

    REALM_FILE="${WORK_DIR}/${realm}.json"
    EXPORT_URL="${KC_BASE_URL}/admin/realms/${realm}/partial-export"
    EXPORT_URL="${EXPORT_URL}?exportClients=true&exportGroupsAndRoles=true"

    HTTP_CODE=$(curl --silent --output "${REALM_FILE}" --write-out "%{http_code}" \
        -X POST "${EXPORT_URL}" \
        -H "Authorization: Bearer ${KC_ADMIN_TOKEN}" \
        -H "Content-Type: application/json")

    if [[ "${HTTP_CODE}" -eq 200 ]] && jq empty "${REALM_FILE}" 2>/dev/null; then
        ((EXPORTED++))
        local_size=$(du -h "${REALM_FILE}" | cut -f1)
        log_success "  Exported: ${realm} (${local_size})"
    else
        ((FAILED++))
        log_error "  Failed to export realm: ${realm} (HTTP ${HTTP_CODE})"
        rm -f "${REALM_FILE}"
    fi
done

# ---------------------------------------------------------------------------
# Create compressed archive
# ---------------------------------------------------------------------------
if [[ ${EXPORTED} -gt 0 ]]; then
    log_info "Creating compressed archive..."

    # Add a metadata file
    cat > "${WORK_DIR}/backup-metadata.json" << METADATA_EOF
{
    "timestamp": "${TIMESTAMP}",
    "environment": "${IAM_ENV}",
    "keycloak_url": "${KC_BASE_URL}",
    "realms_exported": ${EXPORTED},
    "realms_failed": ${FAILED},
    "realms": "$(echo "${REALM_LIST}" | tr ',' ', ')"
}
METADATA_EOF

    tar -czf "${ARCHIVE_FILE}" -C "${OUTPUT_DIR}" "work-${TIMESTAMP}"
    ARCHIVE_SIZE=$(du -h "${ARCHIVE_FILE}" | cut -f1)
    log_success "Archive created: ${ARCHIVE_FILE} (${ARCHIVE_SIZE})"
fi

# ---------------------------------------------------------------------------
# Clean up working directory
# ---------------------------------------------------------------------------
rm -rf "${WORK_DIR}"

# ---------------------------------------------------------------------------
# Rotate old backups
# ---------------------------------------------------------------------------
log_info "Rotating backups older than ${BACKUP_RETENTION_DAYS} days..."
DELETED_COUNT=$(find "${OUTPUT_DIR}" -name "kc-config-*.tar.gz" \
    -mtime "+${BACKUP_RETENTION_DAYS}" -delete -print 2>/dev/null | wc -l || echo 0)
log_info "Deleted ${DELETED_COUNT} old backup(s)."

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
log_section "Backup Summary"
log_kv "Realms Exported" "${EXPORTED}"
log_kv "Realms Failed" "${FAILED}"
log_kv "Archive" "${ARCHIVE_FILE}"
log_kv "Archive Size" "${ARCHIVE_SIZE:-N/A}"

if [[ ${FAILED} -gt 0 ]]; then
    log_warn "Backup completed with ${FAILED} failure(s)."
    exit 1
fi

log_success "Configuration backup completed successfully."
