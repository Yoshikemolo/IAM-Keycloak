#!/usr/bin/env bash
###############################################################################
# common/preconditions.sh
# Prerequisite validation for IAM operational scripts.
#
# Checks required CLI tools, environment variables, and network connectivity
# before script execution begins. Source this file after logging.sh:
#
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "${SCRIPT_DIR}/../common/logging.sh"
#   source "${SCRIPT_DIR}/../common/preconditions.sh"
#
# Functions:
#   require_commands    cmd1 cmd2 ...   -- Verify CLI tools are available
#   require_env_vars    VAR1 VAR2 ...   -- Verify environment variables are set
#   require_file        path            -- Verify a file exists and is readable
#   require_connectivity host port      -- Verify TCP connectivity
#   require_kc_admin_token              -- Obtain and cache Keycloak admin token
#
# Exit codes:
#   3 -- Dependency failure (missing tool, unreachable host)
#   2 -- Misconfiguration (missing env var, missing file)
###############################################################################

# -- Guard against multiple sourcing -----------------------------------------
if [[ -n "${_PRECONDITIONS_SH_LOADED:-}" ]]; then
    return 0
fi
readonly _PRECONDITIONS_SH_LOADED=1

# ---------------------------------------------------------------------------
# require_commands -- Verify that all listed CLI tools are installed.
# Arguments:
#   $@ -- One or more command names to check.
# Returns:
#   Exits with code 3 if any command is missing.
# ---------------------------------------------------------------------------
require_commands() {
    local missing=()
    for cmd in "$@"; do
        if ! command -v "${cmd}" &>/dev/null; then
            missing+=("${cmd}")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required commands: ${missing[*]}"
        log_error "Install the missing tools and ensure they are in PATH."
        exit 3
    fi

    log_debug "All required commands available: $*"
}

# ---------------------------------------------------------------------------
# require_env_vars -- Verify that all listed environment variables are set
#                     and non-empty.
# Arguments:
#   $@ -- One or more variable names to check.
# Returns:
#   Exits with code 2 if any variable is unset or empty.
# ---------------------------------------------------------------------------
require_env_vars() {
    local missing=()
    for var in "$@"; do
        if [[ -z "${!var:-}" ]]; then
            missing+=("${var}")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required environment variables: ${missing[*]}"
        log_error "Set these variables or load the appropriate .env file."
        exit 2
    fi

    log_debug "All required environment variables set: $*"
}

# ---------------------------------------------------------------------------
# require_file -- Verify that a file exists and is readable.
# Arguments:
#   $1 -- File path to check.
# Returns:
#   Exits with code 2 if the file does not exist or is not readable.
# ---------------------------------------------------------------------------
require_file() {
    local filepath="$1"
    if [[ ! -f "${filepath}" ]]; then
        log_error "Required file not found: ${filepath}"
        exit 2
    fi
    if [[ ! -r "${filepath}" ]]; then
        log_error "Required file is not readable: ${filepath}"
        exit 2
    fi
    log_debug "Required file exists: ${filepath}"
}

# ---------------------------------------------------------------------------
# require_connectivity -- Verify TCP connectivity to a host and port.
# Arguments:
#   $1 -- Hostname or IP address.
#   $2 -- Port number.
#   $3 -- Timeout in seconds (default: 5).
# Returns:
#   Exits with code 3 if the connection fails.
# ---------------------------------------------------------------------------
require_connectivity() {
    local host="$1"
    local port="$2"
    local timeout="${3:-5}"

    log_debug "Checking connectivity to ${host}:${port} (timeout: ${timeout}s)"

    if command -v nc &>/dev/null; then
        if ! nc -z -w "${timeout}" "${host}" "${port}" 2>/dev/null; then
            log_error "Cannot connect to ${host}:${port} -- service may be down or unreachable."
            exit 3
        fi
    elif command -v curl &>/dev/null; then
        if ! curl --connect-timeout "${timeout}" --silent --output /dev/null "http://${host}:${port}" 2>/dev/null; then
            log_error "Cannot connect to ${host}:${port} -- service may be down or unreachable."
            exit 3
        fi
    elif command -v bash &>/dev/null; then
        if ! (echo >/dev/tcp/"${host}"/"${port}") 2>/dev/null; then
            log_error "Cannot connect to ${host}:${port} -- service may be down or unreachable."
            exit 3
        fi
    else
        log_warn "No connectivity check tool available (nc, curl). Skipping check for ${host}:${port}."
        return 0
    fi

    log_debug "Connectivity OK: ${host}:${port}"
}

# ---------------------------------------------------------------------------
# require_kc_admin_token -- Obtain a Keycloak admin access token.
# Requires: KC_BASE_URL, KC_ADMIN_USER, KC_ADMIN_PASSWORD
# Sets: KC_ADMIN_TOKEN (exported)
# Returns:
#   Exits with code 1 if token acquisition fails.
# ---------------------------------------------------------------------------
require_kc_admin_token() {
    require_commands curl jq
    require_env_vars KC_BASE_URL KC_ADMIN_USER KC_ADMIN_PASSWORD

    log_info "Acquiring Keycloak admin access token from ${KC_BASE_URL}"

    local response
    response=$(curl --silent --fail --show-error \
        --connect-timeout 10 \
        --max-time 30 \
        -X POST "${KC_BASE_URL}/realms/master/protocol/openid-connect/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=client_credentials&client_id=admin-cli&username=${KC_ADMIN_USER}&password=${KC_ADMIN_PASSWORD}&grant_type=password" \
        2>&1) || {
        log_error "Failed to obtain admin token from Keycloak."
        log_error "Response: ${response}"
        exit 1
    }

    KC_ADMIN_TOKEN=$(echo "${response}" | jq -r '.access_token')
    if [[ -z "${KC_ADMIN_TOKEN}" || "${KC_ADMIN_TOKEN}" == "null" ]]; then
        log_error "Admin token is empty or null. Authentication failed."
        log_debug "Response body: ${response}"
        exit 1
    fi

    export KC_ADMIN_TOKEN
    log_success "Admin token acquired successfully."
}

# ---------------------------------------------------------------------------
# confirm_action -- Prompt the user for confirmation before a destructive
#                   operation. Respects --force flag.
# Arguments:
#   $1 -- Description of the action.
# Returns:
#   0 if confirmed, 1 if declined.
# Globals:
#   FORCE -- If set to "true", skips the prompt.
# ---------------------------------------------------------------------------
confirm_action() {
    local description="$1"

    if [[ "${FORCE:-false}" == "true" ]]; then
        log_warn "Skipping confirmation (--force): ${description}"
        return 0
    fi

    echo ""
    log_warn "You are about to: ${description}"
    read -rp "  Type 'yes' to confirm: " confirmation
    if [[ "${confirmation}" != "yes" ]]; then
        log_info "Operation cancelled by user."
        return 1
    fi
    return 0
}
