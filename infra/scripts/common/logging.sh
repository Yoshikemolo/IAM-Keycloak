#!/usr/bin/env bash
###############################################################################
# common/logging.sh
# Structured logging library for IAM operational scripts.
#
# Provides consistent, colored log output with severity levels and timestamps.
# Source this file at the top of any script that needs logging:
#
#   source "$(dirname "${BASH_SOURCE[0]}")/../common/logging.sh"
#
# Functions:
#   log_info    "message"   -- Informational messages (normal operation)
#   log_warn    "message"   -- Warning conditions (non-fatal issues)
#   log_error   "message"   -- Error conditions (operation failure)
#   log_debug   "message"   -- Debug details (only when LOG_LEVEL=debug)
#   log_success "message"   -- Successful completion of an operation
#   log_fatal   "message"   -- Fatal error; logs and exits with code 1
#   log_section "title"     -- Section header for visual separation
###############################################################################

# -- Guard against multiple sourcing -----------------------------------------
if [[ -n "${_LOGGING_SH_LOADED:-}" ]]; then
    return 0
fi
readonly _LOGGING_SH_LOADED=1

# -- Color codes (disabled when stdout is not a terminal) --------------------
if [[ -t 1 ]]; then
    readonly LOG_RED='\033[0;31m'
    readonly LOG_GREEN='\033[0;32m'
    readonly LOG_YELLOW='\033[1;33m'
    readonly LOG_BLUE='\033[0;34m'
    readonly LOG_CYAN='\033[0;36m'
    readonly LOG_GRAY='\033[0;37m'
    readonly LOG_BOLD='\033[1m'
    readonly LOG_NC='\033[0m'
else
    readonly LOG_RED=''
    readonly LOG_GREEN=''
    readonly LOG_YELLOW=''
    readonly LOG_BLUE=''
    readonly LOG_CYAN=''
    readonly LOG_GRAY=''
    readonly LOG_BOLD=''
    readonly LOG_NC=''
fi

# -- Configuration -----------------------------------------------------------
# LOG_LEVEL: Controls which messages are printed.
#   debug < info < warn < error
# Default: info
LOG_LEVEL="${LOG_LEVEL:-info}"

# LOG_FORMAT: Controls output format.
#   text   -- Human-readable with colors (default)
#   json   -- Structured JSON (for log aggregation)
LOG_FORMAT="${LOG_FORMAT:-text}"

# ---------------------------------------------------------------------------
# Internal: Resolve numeric log level for comparison.
# ---------------------------------------------------------------------------
_log_level_num() {
    case "${1,,}" in
        debug) echo 0 ;;
        info)  echo 1 ;;
        warn)  echo 2 ;;
        error) echo 3 ;;
        *)     echo 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# Internal: Core logging function.
# Arguments:
#   $1 -- severity (INFO, WARN, ERROR, DEBUG, OK)
#   $2 -- color code
#   $3 -- message text
# ---------------------------------------------------------------------------
_log_emit() {
    local severity="$1"
    local color="$2"
    local message="$3"
    local timestamp
    timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

    # Check if this severity should be printed based on LOG_LEVEL
    local current_level
    local threshold_level
    current_level=$(_log_level_num "${severity}")
    threshold_level=$(_log_level_num "${LOG_LEVEL}")

    if [[ "${current_level}" -lt "${threshold_level}" ]]; then
        return 0
    fi

    if [[ "${LOG_FORMAT}" == "json" ]]; then
        # Structured JSON output for log aggregation pipelines
        printf '{"timestamp":"%s","level":"%s","message":"%s","script":"%s"}\n' \
            "${timestamp}" \
            "${severity}" \
            "$(echo "${message}" | sed 's/"/\\"/g')" \
            "${BASH_SOURCE[2]:-unknown}"
    else
        # Human-readable colored output
        printf "${LOG_GRAY}%s${LOG_NC} ${color}[%-5s]${LOG_NC} %s\n" \
            "${timestamp}" \
            "${severity}" \
            "${message}"
    fi
}

# ---------------------------------------------------------------------------
# Public logging functions
# ---------------------------------------------------------------------------

log_info() {
    _log_emit "INFO" "${LOG_CYAN}" "$1"
}

log_warn() {
    _log_emit "WARN" "${LOG_YELLOW}" "$1" >&2
}

log_error() {
    _log_emit "ERROR" "${LOG_RED}" "$1" >&2
}

log_debug() {
    _log_emit "DEBUG" "${LOG_GRAY}" "$1"
}

log_success() {
    _log_emit "OK" "${LOG_GREEN}" "$1"
}

log_fatal() {
    _log_emit "FATAL" "${LOG_RED}" "$1" >&2
    exit 1
}

# ---------------------------------------------------------------------------
# log_section -- Print a visual separator for script sections.
# Arguments:
#   $1 -- Section title
# ---------------------------------------------------------------------------
log_section() {
    local title="$1"
    local width=72
    echo ""
    printf "${LOG_BLUE}${LOG_BOLD}"
    printf '%*s\n' "${width}" '' | tr ' ' '-'
    printf "  %s\n" "${title}"
    printf '%*s\n' "${width}" '' | tr ' ' '-'
    printf "${LOG_NC}"
    echo ""
}

# ---------------------------------------------------------------------------
# log_kv -- Print a key-value pair for structured output.
# Arguments:
#   $1 -- key
#   $2 -- value
# ---------------------------------------------------------------------------
log_kv() {
    local key="$1"
    local value="$2"
    printf "  ${LOG_BOLD}%-20s${LOG_NC} %s\n" "${key}:" "${value}"
}
