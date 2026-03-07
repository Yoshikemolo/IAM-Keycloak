#!/usr/bin/env bash
###############################################################################
# devops-menu.sh -- DevOps helper menu for the Angular 19 IAM-Keycloak example
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
# Resolve project root (one level up from scripts/)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------
print_header() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "============================================================"
    echo "  Angular 19 -- IAM-Keycloak DevOps Menu"
    echo "============================================================"
    echo -e "${NC}"
    echo -e "  ${CYAN}Project:${NC} ${PROJECT_DIR}"
    echo -e "  ${CYAN}Date:${NC}    $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

pause() {
    echo ""
    read -rp "Press Enter to return to the menu..."
}

run_cmd() {
    local description="$1"
    shift
    print_info "Running: $*"
    echo ""
    if "$@"; then
        echo ""
        print_success "${description} completed."
    else
        echo ""
        print_error "${description} failed (exit code $?)."
    fi
}

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------
check_prerequisites() {
    local missing=0

    if ! command -v node &>/dev/null; then
        print_error "Node.js is not installed. Please install Node.js 22.x."
        missing=1
    else
        print_success "Node.js $(node -v) detected."
    fi

    if ! command -v npm &>/dev/null; then
        print_error "npm is not installed."
        missing=1
    else
        print_success "npm $(npm -v) detected."
    fi

    if command -v ng &>/dev/null; then
        print_success "Angular CLI $(ng version 2>/dev/null | grep 'Angular CLI' | awk '{print $NF}') detected."
    else
        print_warn "Angular CLI not found globally. Using npx ng as fallback."
    fi

    if ! command -v docker &>/dev/null; then
        print_warn "Docker is not installed. Docker-related options will not work."
    else
        print_success "Docker $(docker --version | awk '{print $3}' | tr -d ',') detected."
    fi

    if [[ ${missing} -ne 0 ]]; then
        print_error "Missing required prerequisites. Please install them before continuing."
        exit 1
    fi
    echo ""
}

# Determine ng command (global or npx)
NG_CMD="ng"
if ! command -v ng &>/dev/null; then
    NG_CMD="npx ng"
fi

# ---------------------------------------------------------------------------
# Menu actions
# ---------------------------------------------------------------------------
start_keycloak() {
    print_info "Starting Keycloak..."
    local compose_file="${PROJECT_DIR}/../../infrastructure/docker-compose.yml"
    if [[ -f "${compose_file}" ]]; then
        run_cmd "Keycloak startup" docker compose -f "${compose_file}" up -d keycloak
    else
        print_warn "Compose file not found at ${compose_file}."
        print_info "Attempting: docker compose up -d keycloak from project root."
        cd "${PROJECT_DIR}" && run_cmd "Keycloak startup" docker compose up -d keycloak
    fi
}

install_dependencies() {
    cd "${PROJECT_DIR}"
    run_cmd "Dependency installation" npm ci
}

run_dev_server() {
    cd "${PROJECT_DIR}"
    print_info "Starting Angular development server..."
    print_info "Press Ctrl+C to stop."
    echo ""
    ${NG_CMD} serve
}

run_unit_tests() {
    cd "${PROJECT_DIR}"
    run_cmd "Unit tests" ${NG_CMD} test --watch=false
}

run_e2e_tests() {
    cd "${PROJECT_DIR}"
    run_cmd "E2E tests" ${NG_CMD} e2e
}

generate_coverage() {
    cd "${PROJECT_DIR}"
    run_cmd "Coverage report generation" ${NG_CMD} test --watch=false --code-coverage
}

generate_documentation() {
    cd "${PROJECT_DIR}"
    run_cmd "Compodoc documentation generation" npm run compodoc
}

build_production() {
    cd "${PROJECT_DIR}"
    run_cmd "Production build" ${NG_CMD} build --configuration=production
}

build_docker_image() {
    cd "${PROJECT_DIR}"
    run_cmd "Docker image build" docker build -t angular-iam .
}

run_docker_compose() {
    cd "${PROJECT_DIR}"
    run_cmd "Docker Compose up" docker compose up -d
}

run_lint() {
    cd "${PROJECT_DIR}"
    run_cmd "Linting" ${NG_CMD} lint
}

extract_i18n() {
    cd "${PROJECT_DIR}"
    run_cmd "i18n message extraction" ${NG_CMD} extract-i18n
}

view_logs() {
    cd "${PROJECT_DIR}"
    print_info "Showing container logs (Ctrl+C to stop)..."
    docker compose logs -f
}

stop_containers() {
    cd "${PROJECT_DIR}"
    run_cmd "Stopping containers" docker compose down
}

clean_project() {
    cd "${PROJECT_DIR}"
    print_warn "This will remove dist/, node_modules/, and .angular/ directories."
    read -rp "Are you sure? [y/N]: " confirm
    if [[ "${confirm}" =~ ^[Yy]$ ]]; then
        rm -rf dist node_modules .angular
        print_success "Cleaned dist/, node_modules/, and .angular/."
    else
        print_info "Clean cancelled."
    fi
}

# ---------------------------------------------------------------------------
# Main menu
# ---------------------------------------------------------------------------
main() {
    check_prerequisites

    while true; do
        print_header
        echo -e "  ${BOLD} 1)${NC} Start Keycloak"
        echo -e "  ${BOLD} 2)${NC} Install dependencies (npm ci)"
        echo -e "  ${BOLD} 3)${NC} Run development server (ng serve)"
        echo -e "  ${BOLD} 4)${NC} Run unit tests (ng test)"
        echo -e "  ${BOLD} 5)${NC} Run E2E tests (ng e2e)"
        echo -e "  ${BOLD} 6)${NC} Generate coverage report"
        echo -e "  ${BOLD} 7)${NC} Generate documentation (Compodoc)"
        echo -e "  ${BOLD} 8)${NC} Build production (ng build --configuration=production)"
        echo -e "  ${BOLD} 9)${NC} Build Docker image"
        echo -e "  ${BOLD}10)${NC} Run with Docker Compose"
        echo -e "  ${BOLD}11)${NC} Lint (ng lint)"
        echo -e "  ${BOLD}12)${NC} Extract i18n messages (ng extract-i18n)"
        echo -e "  ${BOLD}13)${NC} View logs"
        echo -e "  ${BOLD}14)${NC} Stop containers"
        echo -e "  ${BOLD}15)${NC} Clean (rm -rf dist node_modules .angular)"
        echo ""
        echo -e "  ${BOLD} 0)${NC} Exit"
        echo ""
        read -rp "  Select an option [0-15]: " choice

        case ${choice} in
            1)  start_keycloak         ; pause ;;
            2)  install_dependencies   ; pause ;;
            3)  run_dev_server         ; pause ;;
            4)  run_unit_tests         ; pause ;;
            5)  run_e2e_tests          ; pause ;;
            6)  generate_coverage      ; pause ;;
            7)  generate_documentation ; pause ;;
            8)  build_production       ; pause ;;
            9)  build_docker_image     ; pause ;;
            10) run_docker_compose     ; pause ;;
            11) run_lint               ; pause ;;
            12) extract_i18n           ; pause ;;
            13) view_logs              ; pause ;;
            14) stop_containers        ; pause ;;
            15) clean_project          ; pause ;;
            0)  echo -e "${GREEN}Goodbye.${NC}"; exit 0 ;;
            *)  print_error "Invalid option: ${choice}"; pause ;;
        esac
    done
}

main "$@"
