#!/usr/bin/env bash
###############################################################################
# Keycloak SPI DevOps Menu
# Interactive menu for building, testing, and managing custom Keycloak SPIs.
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
NC='\033[0m' # No Color

# ---------------------------------------------------------------------------
# Project paths
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROVIDERS_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
KEYCLOAK_ROOT="$(cd "${PROVIDERS_ROOT}/.." && pwd)"
DOCKER_COMPOSE_FILE="${KEYCLOAK_ROOT}/docker-compose.yml"
KEYCLOAK_PROVIDERS_DIR="${KEYCLOAK_ROOT}/providers"
TARGET_DIR="${PROVIDERS_ROOT}/target"

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------
print_header() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "============================================================"
    echo "  Keycloak SPI DevOps Menu"
    echo "============================================================"
    echo -e "${NC}"
    echo -e "  ${CYAN}Providers root:${NC} ${PROVIDERS_ROOT}"
    echo -e "  ${CYAN}Keycloak root:${NC}  ${KEYCLOAK_ROOT}"
    echo -e "  ${CYAN}Date:${NC}           $(date '+%Y-%m-%d %H:%M:%S')"
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

press_enter() {
    echo ""
    read -rp "Press Enter to return to the menu..."
}

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------
check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "'$1' is not installed or not in PATH."
        return 1
    fi
    return 0
}

check_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        print_error "Neither 'docker-compose' nor 'docker compose' is available."
        return 1
    fi
    if [[ ! -f "${DOCKER_COMPOSE_FILE}" ]]; then
        print_error "docker-compose.yml not found at: ${DOCKER_COMPOSE_FILE}"
        return 1
    fi
    return 0
}

# ---------------------------------------------------------------------------
# Menu actions
# ---------------------------------------------------------------------------

build_spi_jar() {
    check_command mvn || return
    print_info "Building SPI JAR (skipping tests)..."
    (cd "${PROVIDERS_ROOT}" && mvn package -DskipTests)
    print_success "Build completed. Artifacts available in: ${TARGET_DIR}"
}

run_unit_tests() {
    check_command mvn || return
    print_info "Running unit tests..."
    (cd "${PROVIDERS_ROOT}" && mvn test)
    print_success "Unit tests completed. Reports: ${TARGET_DIR}/surefire-reports/"
}

run_integration_tests() {
    check_command mvn || return
    check_command docker || return
    print_info "Running integration tests (Testcontainers)..."
    (cd "${PROVIDERS_ROOT}" && mvn verify -P integration-tests)
    print_success "Integration tests completed. Reports: ${TARGET_DIR}/failsafe-reports/"
}

deploy_jar_locally() {
    if [[ ! -d "${TARGET_DIR}" ]]; then
        print_error "Target directory not found. Build the JAR first (option 1)."
        return
    fi
    local jar_files
    jar_files=$(find "${TARGET_DIR}" -maxdepth 1 -name "*.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" 2>/dev/null)
    if [[ -z "${jar_files}" ]]; then
        print_error "No JAR files found in ${TARGET_DIR}. Build the JAR first."
        return
    fi
    mkdir -p "${KEYCLOAK_PROVIDERS_DIR}"
    print_info "Copying JAR(s) to ${KEYCLOAK_PROVIDERS_DIR}..."
    while IFS= read -r jar; do
        cp -v "${jar}" "${KEYCLOAK_PROVIDERS_DIR}/"
    done <<< "${jar_files}"
    print_success "JAR(s) deployed to local Keycloak providers directory."
    print_warn "Restart Keycloak for changes to take effect (option 6)."
}

start_keycloak() {
    check_docker_compose || return
    print_info "Starting Keycloak via docker-compose..."
    (cd "${KEYCLOAK_ROOT}" && ${COMPOSE_CMD} up -d)
    print_success "Keycloak containers started."
}

restart_keycloak() {
    check_docker_compose || return
    print_info "Restarting Keycloak container..."
    (cd "${KEYCLOAK_ROOT}" && ${COMPOSE_CMD} restart keycloak)
    print_success "Keycloak restarted."
}

view_keycloak_logs() {
    check_docker_compose || return
    read -rp "Tail lines [200]: " tail_lines
    tail_lines="${tail_lines:-200}"
    print_info "Showing last ${tail_lines} lines of Keycloak logs..."
    (cd "${KEYCLOAK_ROOT}" && ${COMPOSE_CMD} logs --tail="${tail_lines}" keycloak)
}

export_realm() {
    check_docker_compose || return
    read -rp "Realm name [master]: " realm_name
    realm_name="${realm_name:-master}"
    local output_file="${KEYCLOAK_ROOT}/realm-${realm_name}-export.json"
    print_info "Exporting realm '${realm_name}'..."
    (cd "${KEYCLOAK_ROOT}" && ${COMPOSE_CMD} exec keycloak \
        /opt/keycloak/bin/kc.sh export \
        --realm "${realm_name}" \
        --file "/tmp/realm-export.json" 2>/dev/null)
    (cd "${KEYCLOAK_ROOT}" && ${COMPOSE_CMD} cp \
        keycloak:/tmp/realm-export.json "${output_file}")
    print_success "Realm exported to: ${output_file}"
}

import_realm() {
    check_docker_compose || return
    echo ""
    read -rp "Path to realm JSON file: " realm_file
    if [[ ! -f "${realm_file}" ]]; then
        print_error "File not found: ${realm_file}"
        return
    fi
    local filename
    filename="$(basename "${realm_file}")"
    print_info "Importing realm from: ${realm_file}"
    (cd "${KEYCLOAK_ROOT}" && ${COMPOSE_CMD} cp \
        "${realm_file}" "keycloak:/tmp/${filename}")
    (cd "${KEYCLOAK_ROOT}" && ${COMPOSE_CMD} exec keycloak \
        /opt/keycloak/bin/kc.sh import \
        --file "/tmp/${filename}" 2>/dev/null)
    print_success "Realm imported. Restart Keycloak if needed (option 6)."
}

list_providers() {
    check_docker_compose || return
    print_info "Listing installed Keycloak providers..."
    (cd "${KEYCLOAK_ROOT}" && ${COMPOSE_CMD} exec keycloak \
        /opt/keycloak/bin/kcadm.sh get serverinfo \
        --server http://localhost:8080 \
        --realm master \
        --user admin \
        --password admin 2>/dev/null | grep -i "provider" || true)
    echo ""
    print_info "Listing JAR files in the providers directory inside the container..."
    (cd "${KEYCLOAK_ROOT}" && ${COMPOSE_CMD} exec keycloak \
        ls -la /opt/keycloak/providers/ 2>/dev/null || true)
}

test_sms_otp_flow() {
    echo ""
    read -rp "Keycloak base URL [http://localhost:8080]: " base_url
    base_url="${base_url:-http://localhost:8080}"
    read -rp "Realm [master]: " realm
    realm="${realm:-master}"
    read -rp "Client ID [admin-cli]: " client_id
    client_id="${client_id:-admin-cli}"
    read -rp "Username: " username
    read -rsp "Password: " password
    echo ""

    print_info "Step 1: Initiating authentication..."
    local auth_url="${base_url}/realms/${realm}/protocol/openid-connect/auth"
    local token_url="${base_url}/realms/${realm}/protocol/openid-connect/token"

    print_info "Requesting token (first factor)..."
    local response
    response=$(curl -s -w "\n%{http_code}" -X POST "${token_url}" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=password" \
        -d "client_id=${client_id}" \
        -d "username=${username}" \
        -d "password=${password}" 2>&1)

    local http_code
    http_code=$(echo "${response}" | tail -n1)
    local body
    body=$(echo "${response}" | head -n -1)

    echo ""
    print_info "HTTP status: ${http_code}"
    echo "${body}" | python3 -m json.tool 2>/dev/null || echo "${body}"

    if [[ "${http_code}" == "200" ]]; then
        print_success "Authentication succeeded (no OTP challenge -- SPI may not be active on this flow)."
    else
        print_warn "Non-200 response. If an OTP challenge is expected, inspect the response body above."
    fi
}

stop_containers() {
    check_docker_compose || return
    print_info "Stopping all containers..."
    (cd "${KEYCLOAK_ROOT}" && ${COMPOSE_CMD} down)
    print_success "All containers stopped."
}

clean_build() {
    check_command mvn || return
    print_info "Cleaning Maven build artifacts..."
    (cd "${PROVIDERS_ROOT}" && mvn clean)
    print_success "Clean completed."
}

# ---------------------------------------------------------------------------
# Main menu loop
# ---------------------------------------------------------------------------
main() {
    while true; do
        print_header
        echo -e "${BOLD}  Build${NC}"
        echo "    1) Build SPI JAR (mvn package -DskipTests)"
        echo ""
        echo -e "${BOLD}  Test${NC}"
        echo "    2) Run unit tests (mvn test)"
        echo "    3) Run integration tests (mvn verify -P integration-tests)"
        echo ""
        echo -e "${BOLD}  Deploy and Run${NC}"
        echo "    4) Deploy JAR to local Keycloak (copy to providers/)"
        echo "    5) Start local Keycloak (docker-compose up)"
        echo "    6) Restart Keycloak (docker-compose restart keycloak)"
        echo "    7) View Keycloak logs"
        echo ""
        echo -e "${BOLD}  Realm Management${NC}"
        echo "    8) Export realm configuration"
        echo "    9) Import realm configuration"
        echo ""
        echo -e "${BOLD}  Diagnostics${NC}"
        echo "   10) List installed providers (kcadm)"
        echo "   11) Test SMS OTP flow (curl sequence)"
        echo ""
        echo -e "${BOLD}  Lifecycle${NC}"
        echo "   12) Stop containers"
        echo "   13) Clean (mvn clean)"
        echo ""
        echo -e "    ${RED}0) Exit${NC}"
        echo ""
        read -rp "Select an option [0-13]: " choice

        case "${choice}" in
            1)  build_spi_jar ;;
            2)  run_unit_tests ;;
            3)  run_integration_tests ;;
            4)  deploy_jar_locally ;;
            5)  start_keycloak ;;
            6)  restart_keycloak ;;
            7)  view_keycloak_logs ;;
            8)  export_realm ;;
            9)  import_realm ;;
            10) list_providers ;;
            11) test_sms_otp_flow ;;
            12) stop_containers ;;
            13) clean_build ;;
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
