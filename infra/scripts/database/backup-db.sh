#!/usr/bin/env bash
###############################################################################
# database/backup-db.sh
# PostgreSQL database backup with compression and rotation.
#
# Creates a compressed pg_dump backup of the Keycloak database, stores it
# in the configured backup directory, and rotates old backups based on
# retention policy.
#
# Usage:
#   ./backup-db.sh [--format custom|plain|directory] [--output-dir /backups]
#   ./backup-db.sh --format custom --output-dir /mnt/backups
#
# Environment:
#   POSTGRES_HOST       -- Database host (default: localhost)
#   POSTGRES_PORT       -- Database port (default: 5432)
#   POSTGRES_DB         -- Database name (default: keycloak)
#   POSTGRES_USER       -- Database user (default: keycloak)
#   POSTGRES_PASSWORD   -- Database password (required)
#   BACKUP_DIR          -- Backup storage directory
#   BACKUP_RETENTION_DAYS -- Days to keep old backups (default: 30)
#
# Exit codes:
#   0 -- Success
#   1 -- Error (pg_dump failure)
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
DUMP_FORMAT="custom"
OUTPUT_DIR=""
DRY_RUN="false"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --format)     DUMP_FORMAT="$2"; shift 2 ;;
        --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
        --dry-run)    DRY_RUN="true"; shift ;;
        --help|-h)
            echo "Usage: $0 [--format custom|plain|directory] [--output-dir /backups] [--dry-run]"
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
require_commands pg_dump gzip
load_config
validate_config

TIMESTAMP=$(date -u '+%Y%m%dT%H%M%SZ')
OUTPUT_DIR="${OUTPUT_DIR:-${BACKUP_DIR}/database}"
mkdir -p "${OUTPUT_DIR}"

# Determine file extension based on format
case "${DUMP_FORMAT}" in
    custom)    EXTENSION="dump" ;;
    plain)     EXTENSION="sql.gz" ;;
    directory) EXTENSION="dir" ;;
    *)
        log_error "Invalid format: ${DUMP_FORMAT}. Use: custom, plain, directory."
        exit 2
        ;;
esac

BACKUP_FILE="${OUTPUT_DIR}/${POSTGRES_DB}-${IAM_ENV}-${TIMESTAMP}.${EXTENSION}"

# ---------------------------------------------------------------------------
# Display plan
# ---------------------------------------------------------------------------
log_section "Database Backup"
log_kv "Host" "${POSTGRES_HOST}:${POSTGRES_PORT}"
log_kv "Database" "${POSTGRES_DB}"
log_kv "User" "${POSTGRES_USER}"
log_kv "Format" "${DUMP_FORMAT}"
log_kv "Output" "${BACKUP_FILE}"
log_kv "Retention" "${BACKUP_RETENTION_DAYS} days"
log_kv "Environment" "${IAM_ENV}"

if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "Dry-run mode: no backup will be created."
    log_success "Dry-run validation complete."
    exit 0
fi

# ---------------------------------------------------------------------------
# Verify database connectivity
# ---------------------------------------------------------------------------
log_info "Verifying database connectivity..."
export PGPASSWORD="${POSTGRES_PASSWORD}"

if ! pg_isready -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -q 2>/dev/null; then
    log_error "Cannot connect to PostgreSQL at ${POSTGRES_HOST}:${POSTGRES_PORT}."
    exit 3
fi

log_success "Database connection verified."

# ---------------------------------------------------------------------------
# Execute backup
# ---------------------------------------------------------------------------
log_info "Starting database backup..."
BACKUP_START=$(date +%s)

case "${DUMP_FORMAT}" in
    custom)
        pg_dump \
            -h "${POSTGRES_HOST}" \
            -p "${POSTGRES_PORT}" \
            -U "${POSTGRES_USER}" \
            -d "${POSTGRES_DB}" \
            --format=custom \
            --compress=6 \
            --verbose \
            --file="${BACKUP_FILE}" \
            2>&1 | while IFS= read -r line; do log_debug "pg_dump: ${line}"; done
        ;;
    plain)
        pg_dump \
            -h "${POSTGRES_HOST}" \
            -p "${POSTGRES_PORT}" \
            -U "${POSTGRES_USER}" \
            -d "${POSTGRES_DB}" \
            --format=plain \
            --verbose \
            2>&1 | gzip -9 > "${BACKUP_FILE}"
        ;;
    directory)
        pg_dump \
            -h "${POSTGRES_HOST}" \
            -p "${POSTGRES_PORT}" \
            -U "${POSTGRES_USER}" \
            -d "${POSTGRES_DB}" \
            --format=directory \
            --jobs=4 \
            --verbose \
            --file="${BACKUP_FILE}" \
            2>&1 | while IFS= read -r line; do log_debug "pg_dump: ${line}"; done
        ;;
esac

BACKUP_END=$(date +%s)
BACKUP_DURATION=$((BACKUP_END - BACKUP_START))

# Verify backup was created
if [[ ! -e "${BACKUP_FILE}" ]]; then
    log_error "Backup file was not created: ${BACKUP_FILE}"
    exit 1
fi

BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)

# ---------------------------------------------------------------------------
# Rotate old backups
# ---------------------------------------------------------------------------
log_info "Rotating backups older than ${BACKUP_RETENTION_DAYS} days..."
DELETED_COUNT=$(find "${OUTPUT_DIR}" \
    -name "${POSTGRES_DB}-${IAM_ENV}-*" \
    -mtime "+${BACKUP_RETENTION_DAYS}" \
    -delete -print 2>/dev/null | wc -l || echo 0)
if [[ "${DELETED_COUNT}" -gt 0 ]]; then
    log_info "Deleted ${DELETED_COUNT} old backup(s)."
fi

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------
unset PGPASSWORD

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
log_section "Backup Summary"
log_kv "File" "${BACKUP_FILE}"
log_kv "Size" "${BACKUP_SIZE}"
log_kv "Duration" "${BACKUP_DURATION}s"
log_kv "Format" "${DUMP_FORMAT}"
log_kv "Rotated" "${DELETED_COUNT} old backup(s)"

log_success "Database backup completed successfully."
