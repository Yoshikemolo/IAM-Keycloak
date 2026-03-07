#!/usr/bin/env bash
###############################################################################
# common/config.sh
# Configuration loader for IAM operational scripts.
#
# Loads environment-specific configuration from .env files, validates
# required settings, and exports them for use by other scripts.
#
# Source this file after logging.sh and preconditions.sh:
#
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "${SCRIPT_DIR}/../common/logging.sh"
#   source "${SCRIPT_DIR}/../common/preconditions.sh"
#   source "${SCRIPT_DIR}/../common/config.sh"
#
# Functions:
#   load_config         [env]   -- Load .env file for the given environment
#   validate_config             -- Validate that all required vars are set
#   print_config                -- Print current configuration (redacted secrets)
#
# Environment selection priority:
#   1. IAM_ENV environment variable
#   2. Argument passed to load_config
#   3. Default: "dev"
###############################################################################

# -- Guard against multiple sourcing -----------------------------------------
if [[ -n "${_CONFIG_SH_LOADED:-}" ]]; then
    return 0
fi
readonly _CONFIG_SH_LOADED=1

# -- Resolve project root directory ------------------------------------------
# Scripts are under infra/scripts/common/, so project root is three levels up.
CONFIG_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${CONFIG_SCRIPT_DIR}/../../.." && pwd)"
INFRA_ROOT="${PROJECT_ROOT}/infra"
DEVOPS_DIR="${PROJECT_ROOT}/devops"

export PROJECT_ROOT INFRA_ROOT DEVOPS_DIR

# ---------------------------------------------------------------------------
# Default configuration values
# These are used when not overridden by .env files or environment variables.
# ---------------------------------------------------------------------------
: "${IAM_ENV:=dev}"
: "${KC_BASE_URL:=http://localhost:8080}"
: "${KC_ADMIN_USER:=admin}"
: "${KC_ADMIN_PASSWORD:=admin}"
: "${KC_REALM:=master}"
: "${POSTGRES_HOST:=localhost}"
: "${POSTGRES_PORT:=5432}"
: "${POSTGRES_DB:=keycloak}"
: "${POSTGRES_USER:=keycloak}"
: "${POSTGRES_PASSWORD:=changeme}"
: "${BACKUP_DIR:=${INFRA_ROOT}/backups}"
: "${BACKUP_RETENTION_DAYS:=30}"
: "${LOG_LEVEL:=info}"

# ---------------------------------------------------------------------------
# load_config -- Load environment-specific .env file.
# Arguments:
#   $1 -- Environment name (dev, qa, prod). Defaults to IAM_ENV.
# Returns:
#   Sets IAM_ENV and exports all loaded variables.
#   Exits with code 2 if the .env file is not found.
# ---------------------------------------------------------------------------
load_config() {
    local env="${1:-${IAM_ENV}}"
    IAM_ENV="${env}"
    export IAM_ENV

    log_info "Loading configuration for environment: ${IAM_ENV}"

    # Search for .env file in multiple locations (in priority order)
    local env_file=""
    local search_paths=(
        "${DEVOPS_DIR}/.env.${IAM_ENV}"
        "${PROJECT_ROOT}/.env.${IAM_ENV}"
        "${INFRA_ROOT}/.env.${IAM_ENV}"
    )

    for path in "${search_paths[@]}"; do
        if [[ -f "${path}" ]]; then
            env_file="${path}"
            break
        fi
    done

    if [[ -z "${env_file}" ]]; then
        log_warn "No .env.${IAM_ENV} file found. Using defaults and environment variables."
        log_debug "Searched paths: ${search_paths[*]}"
        return 0
    fi

    log_info "Loading env file: ${env_file}"

    # Source the .env file, skipping comments and empty lines
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ -z "${key}" || "${key}" =~ ^[[:space:]]*# ]] && continue

        # Trim whitespace
        key=$(echo "${key}" | xargs)
        value=$(echo "${value}" | xargs)

        # Remove surrounding quotes from value
        value="${value%\"}"
        value="${value#\"}"
        value="${value%\'}"
        value="${value#\'}"

        # Only set if not already set in the environment (env vars take precedence)
        if [[ -z "${!key:-}" ]]; then
            export "${key}=${value}"
            log_debug "Loaded: ${key}=<set>"
        else
            log_debug "Skipped (already set): ${key}"
        fi
    done < "${env_file}"

    log_success "Configuration loaded for environment: ${IAM_ENV}"
}

# ---------------------------------------------------------------------------
# validate_config -- Validate that minimum required configuration is present.
# Returns:
#   Exits with code 2 if required configuration is missing.
# ---------------------------------------------------------------------------
validate_config() {
    log_info "Validating configuration..."

    local errors=0

    # Validate environment name
    case "${IAM_ENV}" in
        dev|qa|prod) ;;
        *)
            log_error "Invalid environment: ${IAM_ENV}. Must be one of: dev, qa, prod."
            ((errors++))
            ;;
    esac

    # Validate Keycloak base URL format
    if [[ ! "${KC_BASE_URL}" =~ ^https?:// ]]; then
        log_error "KC_BASE_URL must start with http:// or https://. Got: ${KC_BASE_URL}"
        ((errors++))
    fi

    # Validate PostgreSQL port is numeric
    if [[ ! "${POSTGRES_PORT}" =~ ^[0-9]+$ ]]; then
        log_error "POSTGRES_PORT must be numeric. Got: ${POSTGRES_PORT}"
        ((errors++))
    fi

    # Warn about default passwords in non-dev environments
    if [[ "${IAM_ENV}" != "dev" ]]; then
        if [[ "${KC_ADMIN_PASSWORD}" == "admin" || "${KC_ADMIN_PASSWORD}" == "changeme" ]]; then
            log_warn "Default admin password detected in ${IAM_ENV} environment. Change it immediately."
        fi
        if [[ "${POSTGRES_PASSWORD}" == "changeme" ]]; then
            log_warn "Default database password detected in ${IAM_ENV} environment. Change it immediately."
        fi
    fi

    if [[ ${errors} -gt 0 ]]; then
        log_error "Configuration validation failed with ${errors} error(s)."
        exit 2
    fi

    log_success "Configuration validation passed."
}

# ---------------------------------------------------------------------------
# print_config -- Print current configuration with secrets redacted.
# ---------------------------------------------------------------------------
print_config() {
    log_section "Current Configuration"
    log_kv "Environment" "${IAM_ENV}"
    log_kv "Project Root" "${PROJECT_ROOT}"
    log_kv "KC Base URL" "${KC_BASE_URL}"
    log_kv "KC Admin User" "${KC_ADMIN_USER}"
    log_kv "KC Admin Password" "********"
    log_kv "KC Realm" "${KC_REALM}"
    log_kv "Postgres Host" "${POSTGRES_HOST}"
    log_kv "Postgres Port" "${POSTGRES_PORT}"
    log_kv "Postgres DB" "${POSTGRES_DB}"
    log_kv "Postgres User" "${POSTGRES_USER}"
    log_kv "Postgres Password" "********"
    log_kv "Backup Dir" "${BACKUP_DIR}"
    log_kv "Backup Retention" "${BACKUP_RETENTION_DAYS} days"
    log_kv "Log Level" "${LOG_LEVEL}"
    echo ""
}
