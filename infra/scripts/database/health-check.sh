#!/usr/bin/env bash
###############################################################################
# database/health-check.sh
# PostgreSQL connectivity and health verification.
#
# Performs multiple checks: TCP connectivity, authentication, query execution,
# replication lag (if applicable), and connection pool status.
#
# Usage:
#   ./health-check.sh [--verbose]
#   ./health-check.sh --verbose
#
# Environment:
#   POSTGRES_HOST       -- Database host (default: localhost)
#   POSTGRES_PORT       -- Database port (default: 5432)
#   POSTGRES_DB         -- Database name (default: keycloak)
#   POSTGRES_USER       -- Database user (default: keycloak)
#   POSTGRES_PASSWORD   -- Database password (required)
#
# Exit codes:
#   0 -- All checks passed
#   1 -- One or more checks failed
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
VERBOSE="false"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose)  VERBOSE="true"; shift ;;
        --help|-h)
            echo "Usage: $0 [--verbose]"
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
require_commands psql
load_config

export PGPASSWORD="${POSTGRES_PASSWORD}"

log_section "PostgreSQL Health Check"
log_kv "Host" "${POSTGRES_HOST}:${POSTGRES_PORT}"
log_kv "Database" "${POSTGRES_DB}"
log_kv "User" "${POSTGRES_USER}"

TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# ---------------------------------------------------------------------------
# Check helper
# ---------------------------------------------------------------------------
run_check() {
    local name="$1"
    local result
    ((TOTAL_CHECKS++))

    if result=$(eval "$2" 2>&1); then
        ((PASSED_CHECKS++))
        log_success "${name}"
        if [[ "${VERBOSE}" == "true" && -n "${result}" ]]; then
            echo "    ${result}"
        fi
    else
        ((FAILED_CHECKS++))
        log_error "${name}"
        if [[ -n "${result}" ]]; then
            log_debug "  Detail: ${result}"
        fi
    fi
}

# ---------------------------------------------------------------------------
# Check 1: pg_isready -- TCP and protocol-level readiness
# ---------------------------------------------------------------------------
run_check "TCP/Protocol readiness (pg_isready)" \
    "pg_isready -h '${POSTGRES_HOST}' -p '${POSTGRES_PORT}' -U '${POSTGRES_USER}' -d '${POSTGRES_DB}' -q"

# ---------------------------------------------------------------------------
# Check 2: Authentication -- Can we actually authenticate?
# ---------------------------------------------------------------------------
run_check "Authentication (SELECT 1)" \
    "psql -h '${POSTGRES_HOST}' -p '${POSTGRES_PORT}' -U '${POSTGRES_USER}' -d '${POSTGRES_DB}' -t -A -c 'SELECT 1;' | grep -q '^1$'"

# ---------------------------------------------------------------------------
# Check 3: Database exists and is accessible
# ---------------------------------------------------------------------------
run_check "Database '${POSTGRES_DB}' accessible" \
    "psql -h '${POSTGRES_HOST}' -p '${POSTGRES_PORT}' -U '${POSTGRES_USER}' -d '${POSTGRES_DB}' -t -A -c \"SELECT current_database()\" | grep -q '${POSTGRES_DB}'"

# ---------------------------------------------------------------------------
# Check 4: Table count (Keycloak schema populated)
# ---------------------------------------------------------------------------
run_check "Schema populated (tables exist)" \
    "test \$(psql -h '${POSTGRES_HOST}' -p '${POSTGRES_PORT}' -U '${POSTGRES_USER}' -d '${POSTGRES_DB}' -t -A -c \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public'\") -gt 0"

# ---------------------------------------------------------------------------
# Check 5: Active connections count
# ---------------------------------------------------------------------------
if [[ "${VERBOSE}" == "true" ]]; then
    log_info "Active connections:"
    psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -t -A \
        -c "SELECT state, COUNT(*) FROM pg_stat_activity WHERE datname='${POSTGRES_DB}' GROUP BY state;" 2>/dev/null \
        | while IFS='|' read -r state count; do
            echo "    ${state:-idle}: ${count}"
        done || true
fi

# ---------------------------------------------------------------------------
# Check 6: Database size
# ---------------------------------------------------------------------------
if [[ "${VERBOSE}" == "true" ]]; then
    DB_SIZE=$(psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -t -A \
        -c "SELECT pg_size_pretty(pg_database_size('${POSTGRES_DB}'));" 2>/dev/null || echo "unknown")
    log_kv "Database Size" "${DB_SIZE}"
fi

# ---------------------------------------------------------------------------
# Check 7: PostgreSQL version
# ---------------------------------------------------------------------------
if [[ "${VERBOSE}" == "true" ]]; then
    PG_VERSION=$(psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -t -A \
        -c "SHOW server_version;" 2>/dev/null || echo "unknown")
    log_kv "PostgreSQL Version" "${PG_VERSION}"
fi

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------
unset PGPASSWORD

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
log_section "Health Check Summary"
log_kv "Total Checks" "${TOTAL_CHECKS}"
log_kv "Passed" "${PASSED_CHECKS}"
log_kv "Failed" "${FAILED_CHECKS}"

if [[ ${FAILED_CHECKS} -gt 0 ]]; then
    log_error "Database health check FAILED: ${FAILED_CHECKS} of ${TOTAL_CHECKS} checks failed."
    exit 1
fi

log_success "All ${TOTAL_CHECKS} database health checks passed."
