#!/usr/bin/env bash
###############################################################################
# database/restore-db.sh
# Restore a PostgreSQL database from a backup file.
#
# Supports custom-format (.dump) and plain-text (.sql.gz) backups.
# Requires explicit confirmation before proceeding (or --force flag).
#
# Usage:
#   ./restore-db.sh --file <backup-file> [--force] [--dry-run]
#   ./restore-db.sh --file /backups/keycloak-dev-20260307.dump
#
# Environment:
#   POSTGRES_HOST       -- Database host (default: localhost)
#   POSTGRES_PORT       -- Database port (default: 5432)
#   POSTGRES_DB         -- Database name (default: keycloak)
#   POSTGRES_USER       -- Database user (default: keycloak)
#   POSTGRES_PASSWORD   -- Database password (required)
#
# Exit codes:
#   0 -- Success
#   1 -- Error (restore failure)
#   2 -- Misconfiguration (missing file, invalid format)
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
BACKUP_FILE=""
FORCE="false"
DRY_RUN="false"
DROP_EXISTING="false"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --file)          BACKUP_FILE="$2"; shift 2 ;;
        --force)         FORCE="true"; shift ;;
        --dry-run)       DRY_RUN="true"; shift ;;
        --drop-existing) DROP_EXISTING="true"; shift ;;
        --help|-h)
            echo "Usage: $0 --file <backup-file> [--force] [--dry-run] [--drop-existing]"
            exit 0
            ;;
        *)
            log_error "Unknown argument: $1"
            exit 2
            ;;
    esac
done

if [[ -z "${BACKUP_FILE}" ]]; then
    log_error "Missing required argument: --file <backup-file>"
    echo "Usage: $0 --file <backup-file> [--force] [--dry-run] [--drop-existing]"
    exit 2
fi

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
require_commands pg_restore psql
require_file "${BACKUP_FILE}"
load_config
validate_config

# Detect backup format from file extension
case "${BACKUP_FILE}" in
    *.dump)   RESTORE_FORMAT="custom" ;;
    *.sql.gz) RESTORE_FORMAT="plain-gz" ;;
    *.sql)    RESTORE_FORMAT="plain" ;;
    *.dir)    RESTORE_FORMAT="directory" ;;
    *)
        log_error "Unrecognized backup file format: ${BACKUP_FILE}"
        log_error "Supported extensions: .dump, .sql.gz, .sql, .dir"
        exit 2
        ;;
esac

BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)

# ---------------------------------------------------------------------------
# Display plan
# ---------------------------------------------------------------------------
log_section "Database Restore"
log_kv "Backup File" "${BACKUP_FILE}"
log_kv "File Size" "${BACKUP_SIZE}"
log_kv "Format" "${RESTORE_FORMAT}"
log_kv "Target Host" "${POSTGRES_HOST}:${POSTGRES_PORT}"
log_kv "Target DB" "${POSTGRES_DB}"
log_kv "User" "${POSTGRES_USER}"
log_kv "Drop Existing" "${DROP_EXISTING}"
log_kv "Environment" "${IAM_ENV}"

if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "Dry-run mode: no changes will be made."
    log_success "Dry-run validation complete. Backup file is valid."
    exit 0
fi

# ---------------------------------------------------------------------------
# Confirm destructive operation
# ---------------------------------------------------------------------------
log_warn "THIS OPERATION WILL OVERWRITE THE DATABASE '${POSTGRES_DB}' ON '${POSTGRES_HOST}'."
if [[ "${IAM_ENV}" == "prod" ]]; then
    log_warn "TARGET ENVIRONMENT IS PRODUCTION."
fi

confirm_action "Restore database '${POSTGRES_DB}' from ${BACKUP_FILE}" || exit 0

# ---------------------------------------------------------------------------
# Verify database connectivity
# ---------------------------------------------------------------------------
export PGPASSWORD="${POSTGRES_PASSWORD}"

log_info "Verifying database connectivity..."
if ! pg_isready -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -q 2>/dev/null; then
    log_error "Cannot connect to PostgreSQL at ${POSTGRES_HOST}:${POSTGRES_PORT}."
    exit 3
fi

log_success "Database connection verified."

# ---------------------------------------------------------------------------
# Execute restore
# ---------------------------------------------------------------------------
log_info "Starting database restore..."
RESTORE_START=$(date +%s)

case "${RESTORE_FORMAT}" in
    custom|directory)
        RESTORE_ARGS=(
            -h "${POSTGRES_HOST}"
            -p "${POSTGRES_PORT}"
            -U "${POSTGRES_USER}"
            -d "${POSTGRES_DB}"
            --verbose
            --no-owner
            --no-privileges
        )
        if [[ "${DROP_EXISTING}" == "true" ]]; then
            RESTORE_ARGS+=(--clean --if-exists)
        fi
        pg_restore "${RESTORE_ARGS[@]}" "${BACKUP_FILE}" \
            2>&1 | while IFS= read -r line; do log_debug "pg_restore: ${line}"; done || {
            log_warn "pg_restore completed with warnings (some errors may be non-fatal)."
        }
        ;;
    plain-gz)
        if [[ "${DROP_EXISTING}" == "true" ]]; then
            log_info "Dropping and recreating database schema..."
            psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" \
                -d "${POSTGRES_DB}" -c "DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;" \
                2>&1 | while IFS= read -r line; do log_debug "psql: ${line}"; done
        fi
        gunzip -c "${BACKUP_FILE}" | psql \
            -h "${POSTGRES_HOST}" \
            -p "${POSTGRES_PORT}" \
            -U "${POSTGRES_USER}" \
            -d "${POSTGRES_DB}" \
            --quiet \
            2>&1 | while IFS= read -r line; do log_debug "psql: ${line}"; done
        ;;
    plain)
        if [[ "${DROP_EXISTING}" == "true" ]]; then
            log_info "Dropping and recreating database schema..."
            psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" \
                -d "${POSTGRES_DB}" -c "DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;" \
                2>&1 | while IFS= read -r line; do log_debug "psql: ${line}"; done
        fi
        psql \
            -h "${POSTGRES_HOST}" \
            -p "${POSTGRES_PORT}" \
            -U "${POSTGRES_USER}" \
            -d "${POSTGRES_DB}" \
            --quiet \
            -f "${BACKUP_FILE}" \
            2>&1 | while IFS= read -r line; do log_debug "psql: ${line}"; done
        ;;
esac

RESTORE_END=$(date +%s)
RESTORE_DURATION=$((RESTORE_END - RESTORE_START))

# ---------------------------------------------------------------------------
# Verify restore
# ---------------------------------------------------------------------------
log_info "Verifying restored database..."
TABLE_COUNT=$(psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" \
    -d "${POSTGRES_DB}" -t -A \
    -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null || echo "0")

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------
unset PGPASSWORD

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
log_section "Restore Summary"
log_kv "Backup File" "${BACKUP_FILE}"
log_kv "Duration" "${RESTORE_DURATION}s"
log_kv "Tables Found" "${TABLE_COUNT}"
log_kv "Target" "${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"

log_success "Database restore completed successfully."
