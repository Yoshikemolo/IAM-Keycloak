#!/usr/bin/env bash
###############################################################################
# keycloak/health-check.sh
# Check Keycloak health, readiness, and liveness endpoints.
#
# Usage:
#   ./health-check.sh [--url <base-url>] [--verbose]
#   ./health-check.sh --url https://iam.example.com
#
# Checks:
#   1. /health/ready   -- Readiness probe (DB connection, providers loaded)
#   2. /health/live    -- Liveness probe (JVM is responsive)
#   3. /health         -- Overall health summary
#   4. /realms/master  -- Realm endpoint accessibility
#
# Exit codes:
#   0 -- All health checks passed
#   1 -- One or more health checks failed
#   3 -- Dependency failure (curl not available)
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
CUSTOM_URL=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --url)      CUSTOM_URL="$2"; shift 2 ;;
        --verbose)  VERBOSE="true"; shift ;;
        --help|-h)
            echo "Usage: $0 [--url <base-url>] [--verbose]"
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
require_commands curl jq
load_config

if [[ -n "${CUSTOM_URL}" ]]; then
    KC_BASE_URL="${CUSTOM_URL}"
fi

# Management port (9000) for health endpoints; fall back to main port
KC_MGMT_URL="${KC_MGMT_URL:-${KC_BASE_URL}}"
# If base URL uses port 8080, try management port 9000
if [[ "${KC_MGMT_URL}" == *":8080"* ]]; then
    KC_MGMT_URL="${KC_MGMT_URL//:8080/:9000}"
fi

log_section "Keycloak Health Check"
log_kv "Target URL" "${KC_BASE_URL}"
log_kv "Management URL" "${KC_MGMT_URL}"

# ---------------------------------------------------------------------------
# Health check function
# ---------------------------------------------------------------------------
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

check_endpoint() {
    local name="$1"
    local url="$2"
    local expected_code="${3:-200}"

    ((TOTAL_CHECKS++))

    local http_code
    local response_body
    local response_time

    response_body=$(mktemp)
    http_code=$(curl --silent --output "${response_body}" --write-out "%{http_code}" \
        --connect-timeout 10 --max-time 30 "${url}" 2>/dev/null) || http_code="000"

    response_time=$(curl --silent --output /dev/null --write-out "%{time_total}" \
        --connect-timeout 10 --max-time 30 "${url}" 2>/dev/null) || response_time="N/A"

    if [[ "${http_code}" == "${expected_code}" ]]; then
        ((PASSED_CHECKS++))
        log_success "${name}: HTTP ${http_code} (${response_time}s)"
        if [[ "${VERBOSE}" == "true" && -f "${response_body}" ]]; then
            jq . "${response_body}" 2>/dev/null || cat "${response_body}"
        fi
    else
        ((FAILED_CHECKS++))
        log_error "${name}: HTTP ${http_code} (expected ${expected_code})"
        if [[ -f "${response_body}" ]]; then
            local body
            body=$(cat "${response_body}" 2>/dev/null || echo "<empty>")
            if [[ -n "${body}" ]]; then
                log_debug "Response: ${body}"
            fi
        fi
    fi

    rm -f "${response_body}"
}

# ---------------------------------------------------------------------------
# Run health checks
# ---------------------------------------------------------------------------

# 1. Readiness probe -- verifies DB and providers are ready
check_endpoint "Readiness (/health/ready)" "${KC_MGMT_URL}/health/ready"

# 2. Liveness probe -- verifies JVM is responsive
check_endpoint "Liveness  (/health/live)" "${KC_MGMT_URL}/health/live"

# 3. Overall health summary
check_endpoint "Health    (/health)" "${KC_MGMT_URL}/health"

# 4. Realm endpoint -- verifies application-level functionality
check_endpoint "Realm     (/realms/master)" "${KC_BASE_URL}/realms/master"

# 5. OpenID Connect Discovery (optional but useful)
check_endpoint "OIDC      (well-known)" \
    "${KC_BASE_URL}/realms/master/.well-known/openid-configuration"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
log_section "Health Check Summary"
log_kv "Total Checks" "${TOTAL_CHECKS}"
log_kv "Passed" "${PASSED_CHECKS}"
log_kv "Failed" "${FAILED_CHECKS}"

if [[ ${FAILED_CHECKS} -gt 0 ]]; then
    log_error "Keycloak health check FAILED: ${FAILED_CHECKS} of ${TOTAL_CHECKS} checks failed."
    exit 1
fi

log_success "All ${TOTAL_CHECKS} health checks passed."
exit 0
