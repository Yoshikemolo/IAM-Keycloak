#!/usr/bin/env bash
###############################################################################
# operations/health-check-all.sh
# End-to-end health check for the entire IAM platform.
#
# Verifies Keycloak, PostgreSQL, Kubernetes ingress, and supporting services
# are operational. Designed for use in monitoring pipelines, runbooks, and
# incident triage.
#
# Usage:
#   ./health-check-all.sh [--verbose] [--json]
#   ./health-check-all.sh --verbose
#
# Checks performed:
#   1. PostgreSQL database connectivity and query execution
#   2. Keycloak health (readiness, liveness, realm)
#   3. Keycloak Admin API accessibility
#   4. Ingress/load balancer endpoint (if configured)
#   5. Prometheus endpoint (if configured)
#   6. Grafana endpoint (if configured)
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
OUTPUT_JSON="false"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose)  VERBOSE="true"; shift ;;
        --json)     OUTPUT_JSON="true"; LOG_FORMAT="json"; shift ;;
        --help|-h)
            echo "Usage: $0 [--verbose] [--json]"
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
require_commands curl
load_config

# Optional variables for extended checks
: "${INGRESS_URL:=}"
: "${PROMETHEUS_URL:=http://localhost:9090}"
: "${GRAFANA_URL:=http://localhost:3000}"

log_section "IAM Platform End-to-End Health Check"
log_kv "Environment" "${IAM_ENV}"
log_kv "Keycloak URL" "${KC_BASE_URL}"
log_kv "Database Host" "${POSTGRES_HOST}:${POSTGRES_PORT}"
log_kv "Timestamp" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

TOTAL=0
PASSED=0
FAILED=0
RESULTS=()

# ---------------------------------------------------------------------------
# Generic check helper
# ---------------------------------------------------------------------------
check() {
    local component="$1"
    local name="$2"
    local cmd="$3"
    local result_msg

    ((TOTAL++))

    if result_msg=$(eval "${cmd}" 2>&1); then
        ((PASSED++))
        log_success "[${component}] ${name}"
        RESULTS+=("{\"component\":\"${component}\",\"check\":\"${name}\",\"status\":\"pass\"}")
    else
        ((FAILED++))
        log_error "[${component}] ${name}"
        if [[ "${VERBOSE}" == "true" && -n "${result_msg}" ]]; then
            log_debug "  ${result_msg}"
        fi
        RESULTS+=("{\"component\":\"${component}\",\"check\":\"${name}\",\"status\":\"fail\",\"detail\":\"${result_msg}\"}")
    fi
}

http_check() {
    local component="$1"
    local name="$2"
    local url="$3"
    local expected="${4:-200}"

    ((TOTAL++))

    local http_code
    http_code=$(curl --silent --output /dev/null --write-out "%{http_code}" \
        --connect-timeout 10 --max-time 30 "${url}" 2>/dev/null) || http_code="000"

    if [[ "${http_code}" == "${expected}" ]]; then
        ((PASSED++))
        log_success "[${component}] ${name} (HTTP ${http_code})"
        RESULTS+=("{\"component\":\"${component}\",\"check\":\"${name}\",\"status\":\"pass\",\"http_code\":${http_code}}")
    else
        ((FAILED++))
        log_error "[${component}] ${name} (HTTP ${http_code}, expected ${expected})"
        RESULTS+=("{\"component\":\"${component}\",\"check\":\"${name}\",\"status\":\"fail\",\"http_code\":${http_code}}")
    fi
}

# ---------------------------------------------------------------------------
# 1. PostgreSQL checks
# ---------------------------------------------------------------------------
log_section "PostgreSQL"

if command -v psql &>/dev/null; then
    export PGPASSWORD="${POSTGRES_PASSWORD}"

    check "PostgreSQL" "pg_isready" \
        "pg_isready -h '${POSTGRES_HOST}' -p '${POSTGRES_PORT}' -U '${POSTGRES_USER}' -d '${POSTGRES_DB}' -q"

    check "PostgreSQL" "Query execution (SELECT 1)" \
        "psql -h '${POSTGRES_HOST}' -p '${POSTGRES_PORT}' -U '${POSTGRES_USER}' -d '${POSTGRES_DB}' -t -A -c 'SELECT 1;' | grep -q '^1$'"

    check "PostgreSQL" "Schema populated" \
        "test \$(psql -h '${POSTGRES_HOST}' -p '${POSTGRES_PORT}' -U '${POSTGRES_USER}' -d '${POSTGRES_DB}' -t -A -c \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public'\") -gt 0"

    unset PGPASSWORD
else
    log_warn "[PostgreSQL] psql not available -- skipping database checks."
fi

# ---------------------------------------------------------------------------
# 2. Keycloak checks
# ---------------------------------------------------------------------------
log_section "Keycloak"

KC_MGMT_URL="${KC_MGMT_URL:-${KC_BASE_URL}}"
if [[ "${KC_MGMT_URL}" == *":8080"* ]]; then
    KC_MGMT_URL="${KC_MGMT_URL//:8080/:9000}"
fi

http_check "Keycloak" "Readiness (/health/ready)" "${KC_MGMT_URL}/health/ready"
http_check "Keycloak" "Liveness (/health/live)" "${KC_MGMT_URL}/health/live"
http_check "Keycloak" "Realm (master)" "${KC_BASE_URL}/realms/master"
http_check "Keycloak" "OIDC Discovery" \
    "${KC_BASE_URL}/realms/master/.well-known/openid-configuration"

# ---------------------------------------------------------------------------
# 3. Ingress check (optional)
# ---------------------------------------------------------------------------
if [[ -n "${INGRESS_URL}" ]]; then
    log_section "Ingress"
    http_check "Ingress" "External endpoint" "${INGRESS_URL}" "200"
    http_check "Ingress" "TLS handshake" "${INGRESS_URL}/realms/master" "200"
fi

# ---------------------------------------------------------------------------
# 4. Prometheus check (optional)
# ---------------------------------------------------------------------------
log_section "Monitoring"

http_check "Prometheus" "API health" "${PROMETHEUS_URL}/-/healthy"
http_check "Grafana" "API health" "${GRAFANA_URL}/api/health"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
log_section "Overall Summary"
log_kv "Total Checks" "${TOTAL}"
log_kv "Passed" "${PASSED}"
log_kv "Failed" "${FAILED}"
log_kv "Status" "$(if [[ ${FAILED} -eq 0 ]]; then echo 'HEALTHY'; else echo 'DEGRADED'; fi)"

# Output JSON summary if requested
if [[ "${OUTPUT_JSON}" == "true" ]]; then
    echo "{"
    echo "  \"timestamp\": \"$(date -u '+%Y-%m-%dT%H:%M:%SZ')\","
    echo "  \"environment\": \"${IAM_ENV}\","
    echo "  \"total\": ${TOTAL},"
    echo "  \"passed\": ${PASSED},"
    echo "  \"failed\": ${FAILED},"
    echo "  \"status\": \"$(if [[ ${FAILED} -eq 0 ]]; then echo 'healthy'; else echo 'degraded'; fi)\","
    echo "  \"checks\": ["
    local first=true
    for r in "${RESULTS[@]}"; do
        if [[ "${first}" == "true" ]]; then
            echo "    ${r}"
            first=false
        else
            echo "    ,${r}"
        fi
    done
    echo "  ]"
    echo "}"
fi

if [[ ${FAILED} -gt 0 ]]; then
    log_error "Platform health check FAILED: ${FAILED} of ${TOTAL} checks failed."
    exit 1
fi

log_success "All ${TOTAL} platform health checks passed. System is healthy."
