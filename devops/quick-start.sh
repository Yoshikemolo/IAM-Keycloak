#!/usr/bin/env bash
###############################################################################
# IAM Platform - Quick Start Script
#
# Interactive launcher to deploy any component of the IAM platform locally.
# Supports environment selection (dev, qa, prod), individual service control,
# and status monitoring.
#
# Usage:
#   ./quick-start.sh              # Interactive mode
#   ./quick-start.sh --env dev    # Pre-select environment
###############################################################################

set -euo pipefail

# ---------------------------------------------------------------------------
# Colors and formatting
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ---------------------------------------------------------------------------
# Project paths
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.base.yml"
ENV_FILE=""
SELECTED_ENV=""

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------
print_header() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "============================================================"
    echo "  IAM Platform - Quick Start"
    echo "============================================================"
    echo -e "${NC}"
    echo -e "  ${CYAN}Project root:${NC}  ${PROJECT_ROOT}"
    echo -e "  ${CYAN}Environment:${NC}   ${SELECTED_ENV:-not selected}"
    echo -e "  ${CYAN}Date:${NC}          $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
print_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_info()    { echo -e "${CYAN}[INFO]${NC} $1"; }

press_enter() {
    echo ""
    read -rp "Press Enter to return to the menu..."
}

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------
check_prerequisites() {
    local missing=0

    for cmd in docker git; do
        if ! command -v "${cmd}" &>/dev/null; then
            print_error "'${cmd}' is not installed or not in PATH."
            missing=1
        fi
    done

    if ! docker compose version &>/dev/null && ! command -v docker-compose &>/dev/null; then
        print_error "Neither 'docker compose' nor 'docker-compose' is available."
        missing=1
    fi

    if ! docker info &>/dev/null 2>&1; then
        print_error "Docker daemon is not running."
        missing=1
    fi

    if [[ ${missing} -eq 1 ]]; then
        echo ""
        print_error "Please install missing prerequisites and try again."
        exit 1
    fi

    print_success "All prerequisites satisfied."
}

compose_cmd() {
    if docker compose version &>/dev/null 2>&1; then
        docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" "$@"
    else
        docker-compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" "$@"
    fi
}

# ---------------------------------------------------------------------------
# Environment selection
# ---------------------------------------------------------------------------
select_environment() {
    echo -e "${BOLD}  Select environment:${NC}"
    echo ""
    echo "    1) dev   - Local development (debug logging, no TLS)"
    echo "    2) qa    - Staging / QA (production-like settings)"
    echo "    3) prod  - Production template (requires secret replacement)"
    echo ""
    read -rp "  Environment [1]: " env_choice
    env_choice="${env_choice:-1}"

    case "${env_choice}" in
        1) SELECTED_ENV="dev"  ; ENV_FILE="${SCRIPT_DIR}/.env.dev"  ;;
        2) SELECTED_ENV="qa"   ; ENV_FILE="${SCRIPT_DIR}/.env.qa"   ;;
        3) SELECTED_ENV="prod" ; ENV_FILE="${SCRIPT_DIR}/.env.prod" ;;
        *)
            print_error "Invalid selection: ${env_choice}"
            select_environment
            return
            ;;
    esac

    if [[ ! -f "${ENV_FILE}" ]]; then
        print_error "Environment file not found: ${ENV_FILE}"
        exit 1
    fi

    print_success "Environment set to: ${SELECTED_ENV}"
}

# ---------------------------------------------------------------------------
# Menu actions
# ---------------------------------------------------------------------------
start_all() {
    print_info "Starting all IAM platform services (${SELECTED_ENV})..."
    compose_cmd up -d
    echo ""
    print_success "All services started."
    echo ""
    print_info "Keycloak Admin Console: http://localhost:8080/admin"
    print_info "Prometheus:             http://localhost:9090"
    print_info "Grafana:                http://localhost:3000"
}

stop_all() {
    print_info "Stopping all services..."
    compose_cmd down
    print_success "All services stopped."
}

restart_all() {
    print_info "Restarting all services..."
    compose_cmd restart
    print_success "All services restarted."
}

recreate_containers() {
    echo ""
    echo -e "  ${BOLD}Recreate containers:${NC}"
    echo "    1) All services (stop, remove, and create fresh containers)"
    echo "    2) Keycloak only"
    echo "    3) PostgreSQL only"
    echo ""
    read -rp "  Selection [1]: " recreate_choice
    recreate_choice="${recreate_choice:-1}"

    case "${recreate_choice}" in
        1)
            print_info "Recreating all containers (${SELECTED_ENV})..."
            compose_cmd down
            compose_cmd up -d
            print_success "All containers recreated."
            ;;
        2)
            print_info "Recreating Keycloak container..."
            compose_cmd stop keycloak
            compose_cmd rm -f keycloak
            compose_cmd up -d keycloak
            print_success "Keycloak container recreated."
            ;;
        3)
            print_info "Recreating PostgreSQL container..."
            compose_cmd stop postgres
            compose_cmd rm -f postgres
            compose_cmd up -d postgres
            print_success "PostgreSQL container recreated."
            ;;
        *)
            print_error "Invalid selection"
            return
            ;;
    esac

    echo ""
    print_info "Keycloak Admin Console: http://localhost:8080/admin"
}

show_status() {
    print_info "Service status:"
    echo ""
    compose_cmd ps
}

show_logs() {
    echo ""
    echo -e "  ${BOLD}Select service:${NC}"
    echo "    1) keycloak"
    echo "    2) postgres"
    echo "    3) prometheus"
    echo "    4) grafana"
    echo "    5) all"
    echo ""
    read -rp "  Service [1]: " svc_choice
    svc_choice="${svc_choice:-1}"

    local service=""
    case "${svc_choice}" in
        1) service="keycloak"  ;;
        2) service="postgres"  ;;
        3) service="prometheus";;
        4) service="grafana"   ;;
        5) service=""          ;;
        *) print_error "Invalid selection"; return ;;
    esac

    read -rp "  Tail lines [100]: " tail_lines
    tail_lines="${tail_lines:-100}"

    compose_cmd logs --tail="${tail_lines}" ${service}
}

health_check() {
    print_info "Running health checks..."
    echo ""

    local kc_url="http://localhost:${KEYCLOAK_MANAGEMENT_PORT:-9000}/health/ready"
    if curl -sf "${kc_url}" >/dev/null 2>&1; then
        print_success "Keycloak: healthy"
    else
        print_error "Keycloak: unreachable at ${kc_url}"
    fi

    if curl -sf "http://localhost:9090/-/healthy" >/dev/null 2>&1; then
        print_success "Prometheus: healthy"
    else
        print_error "Prometheus: unreachable"
    fi

    if curl -sf "http://localhost:3000/api/health" >/dev/null 2>&1; then
        print_success "Grafana: healthy"
    else
        print_error "Grafana: unreachable"
    fi

    local pg_container="iam-postgres"
    if docker exec "${pg_container}" pg_isready -U keycloak >/dev/null 2>&1; then
        print_success "PostgreSQL: healthy"
    else
        print_error "PostgreSQL: unreachable"
    fi
}

build_spi() {
    if ! command -v mvn &>/dev/null; then
        print_error "Maven is not installed. Cannot build SPI providers."
        return
    fi

    # Ensure JAVA_HOME points to a JDK (not a JRE) so Maven can find javac.
    # If the current JAVA_HOME lacks bin/javac, scan common installation dirs.
    detect_jdk() {
        local candidate_dirs=(
            "/c/Program Files/Eclipse Adoptium"
            "/c/Program Files/Java"
            "/c/Program Files/Microsoft/jdk"
            "/c/Program Files/BellSoft"
            "/c/Program Files/Amazon Corretto"
            "/usr/lib/jvm"
            "/opt/java"
        )

        for base in "${candidate_dirs[@]}"; do
            [[ -d "${base}" ]] || continue
            for dir in "${base}"/jdk-*/ "${base}"/jdk*/; do
                if [[ -f "${dir}bin/javac" || -f "${dir}bin/javac.exe" ]]; then
                    # Remove trailing slash for clean path
                    echo "${dir%/}"
                    return 0
                fi
            done
        done
        return 1
    }

    local effective_java_home="${JAVA_HOME:-}"

    # Check if current JAVA_HOME has a compiler
    if [[ -z "${effective_java_home}" ]] || \
       { [[ ! -f "${effective_java_home}/bin/javac" ]] && [[ ! -f "${effective_java_home}/bin/javac.exe" ]]; }; then

        print_warn "JAVA_HOME is not set or points to a JRE without javac."
        if [[ -n "${effective_java_home}" ]]; then
            print_warn "Current JAVA_HOME: ${effective_java_home}"
        fi

        print_info "Scanning for an installed JDK..."
        local detected_jdk
        if detected_jdk="$(detect_jdk)"; then
            print_success "Found JDK: ${detected_jdk}"
            effective_java_home="${detected_jdk}"
        else
            print_error "No JDK installation found. Install a JDK (e.g. Eclipse Temurin 17+) and set JAVA_HOME."
            return
        fi
    fi

    print_info "Using JAVA_HOME: ${effective_java_home}"
    print_info "Building custom SPI providers..."
    if (cd "${PROJECT_ROOT}/keycloak/providers" && JAVA_HOME="${effective_java_home}" mvn package -DskipTests); then
        print_success "SPI JAR built: keycloak/providers/target/keycloak-custom-providers.jar"
        print_info "Restart Keycloak to pick up changes."
    else
        print_error "SPI build failed. Check the Maven output above for details."
    fi
}

import_realm() {
    local realm_dir="${PROJECT_ROOT}/keycloak/realms"
    local realm_files
    realm_files=$(find "${realm_dir}" -name "*.json" 2>/dev/null)

    if [[ -z "${realm_files}" ]]; then
        print_error "No realm JSON files found in ${realm_dir}"
        return
    fi

    echo ""
    print_info "Available realm files:"
    echo "${realm_files}" | while IFS= read -r f; do
        echo "    - $(basename "${f}")"
    done
    echo ""
    print_info "Realms are auto-imported on Keycloak startup (--import-realm)."
    print_info "To force re-import, restart Keycloak (option 3)."
}

destroy_volumes() {
    print_warn "This will DELETE all persistent data (database, metrics, dashboards)."
    read -rp "Are you sure? [y/N]: " confirm
    if [[ "${confirm}" =~ ^[Yy]$ ]]; then
        compose_cmd down -v
        print_success "All services stopped and volumes removed."
    else
        print_info "Cancelled."
    fi
}

start_example_project() {
    local examples_dir="${PROJECT_ROOT}/examples/backend"
    echo ""
    echo -e "  ${BOLD}Select example project:${NC}"
    echo ""

    local i=1
    local projects=()
    for dir in "${examples_dir}"/*/; do
        if [[ -f "${dir}docker-compose.yml" ]]; then
            local name
            name="$(basename "${dir}")"
            projects+=("${name}")
            echo "    ${i}) ${name}"
            i=$((i + 1))
        fi
    done

    if [[ ${#projects[@]} -eq 0 ]]; then
        print_error "No example projects with docker-compose.yml found."
        return
    fi

    echo ""
    read -rp "  Project number: " proj_choice

    if [[ -z "${proj_choice}" ]] || [[ ${proj_choice} -lt 1 ]] || [[ ${proj_choice} -gt ${#projects[@]} ]]; then
        print_error "Invalid selection"
        return
    fi

    local selected="${projects[$((proj_choice - 1))]}"
    local proj_dir="${examples_dir}/${selected}"

    print_info "Starting ${selected}..."
    if docker compose version &>/dev/null 2>&1; then
        docker compose -f "${proj_dir}/docker-compose.yml" up -d
    else
        docker-compose -f "${proj_dir}/docker-compose.yml" up -d
    fi
    print_success "${selected} started."
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --env)
            SELECTED_ENV="$2"
            ENV_FILE="${SCRIPT_DIR}/.env.${SELECTED_ENV}"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    check_prerequisites

    if [[ -z "${SELECTED_ENV}" ]]; then
        print_header
        select_environment
    fi

    # Source env file for variable expansion in health checks
    set -a
    source "${ENV_FILE}"
    set +a

    while true; do
        print_header
        echo -e "${BOLD}  Platform Services${NC}"
        echo "    1) Start all services"
        echo "    2) Stop all services"
        echo "    3) Restart all services"
        echo "    4) Recreate containers"
        echo ""
        echo -e "${BOLD}  Monitoring${NC}"
        echo "    5) Show service status"
        echo "    6) View logs"
        echo "    7) Health check"
        echo ""
        echo -e "${BOLD}  Build and Deploy${NC}"
        echo "    8) Build custom SPI providers (Maven)"
        echo "    9) Realm import info"
        echo "   10) Start an example project"
        echo ""
        echo -e "${BOLD}  Cleanup${NC}"
        echo "   11) Destroy all data (volumes)"
        echo ""
        echo -e "    ${RED}0) Exit${NC}"
        echo ""
        read -rp "  Select an option [0-11]: " choice

        case "${choice}" in
            1)  start_all ;;
            2)  stop_all ;;
            3)  restart_all ;;
            4)  recreate_containers ;;
            5)  show_status ;;
            6)  show_logs ;;
            7)  health_check ;;
            8)  build_spi ;;
            9)  import_realm ;;
            10) start_example_project ;;
            11) destroy_volumes ;;
            0)
                echo ""
                print_info "Exiting. Goodbye."
                exit 0
                ;;
            *)
                print_error "Invalid option: ${choice}"
                ;;
        esac
        press_enter
    done
}

main "$@"
