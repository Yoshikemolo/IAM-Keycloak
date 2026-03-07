#!/usr/bin/env bash
#
# devops-menu.sh -- Interactive DevOps Menu for Express IAM Resource Server
#
# This script provides a numbered menu of common development and operations
# tasks for the Express IAM example project. It wraps npm, Docker, and
# Docker Compose commands so that developers can perform routine tasks
# without memorizing individual commands.
#
# Usage:
#   ./scripts/devops-menu.sh
#
# Prerequisites:
#   - Node.js 22.x
#   - npm 10.x+
#   - Docker 24+ and Docker Compose 2.x
#
# The script must be run from the project root directory (examples/node/express).
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Project name displayed in the menu header
PROJECT_NAME="Express IAM Resource Server"

# Docker image name for the application
DOCKER_IMAGE="iam-express"

# Resolve project root directory (parent of scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

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
# Helper functions
# ---------------------------------------------------------------------------

# Print a colored header banner
print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}============================================${NC}"
    echo -e "${BLUE}${BOLD}  ${PROJECT_NAME}${NC}"
    echo -e "${BLUE}${BOLD}  DevOps Menu${NC}"
    echo -e "${BLUE}${BOLD}============================================${NC}"
    echo ""
}

# Print an informational message
info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Print a success message
success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

# Print a warning message
warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Print an error message
error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if a command is available on the system
check_command() {
    if ! command -v "$1" &> /dev/null; then
        error "$1 is not installed or not in PATH."
        return 1
    fi
}

# Check that required tools are installed before proceeding
check_prerequisites() {
    local missing=0

    if ! check_command node; then missing=1; fi
    if ! check_command npm; then missing=1; fi
    if ! check_command docker; then missing=1; fi

    if [[ $missing -eq 1 ]]; then
        error "Some prerequisites are missing. Please install them before continuing."
        return 1
    fi

    # Verify Node.js major version is 22+
    local node_version
    node_version=$(node --version | sed 's/v//' | cut -d. -f1)
    if [[ "$node_version" -lt 22 ]]; then
        warn "Node.js 22.x is recommended. Current version: $(node --version)"
    fi

    success "All prerequisites satisfied."
}

# Pause and wait for the user to press Enter
pause() {
    echo ""
    read -rp "Press Enter to return to the menu..."
}

# ---------------------------------------------------------------------------
# Menu option implementations
# ---------------------------------------------------------------------------

# Option 1: Start Keycloak using Docker Compose
start_keycloak() {
    info "Starting Keycloak via Docker Compose..."
    cd "$PROJECT_ROOT"
    docker-compose up -d keycloak
    success "Keycloak is starting. Access it at http://localhost:8080"
}

# Option 2: Install project dependencies
install_dependencies() {
    info "Installing dependencies with npm ci..."
    cd "$PROJECT_ROOT"
    npm ci
    success "Dependencies installed."
}

# Option 3: Run the Express application in development mode
run_application() {
    info "Starting the Express application in development mode..."
    cd "$PROJECT_ROOT"
    npm run start:dev
}

# Option 4: Run unit tests
run_unit_tests() {
    info "Running unit tests..."
    cd "$PROJECT_ROOT"
    npm test
    success "Unit tests complete."
}

# Option 5: Run end-to-end tests
run_e2e_tests() {
    info "Running end-to-end tests..."
    cd "$PROJECT_ROOT"
    npm run test:e2e
    success "E2E tests complete."
}

# Option 6: Generate code coverage report
generate_coverage() {
    info "Generating code coverage report..."
    cd "$PROJECT_ROOT"
    npm run test:cov
    success "Coverage report generated at coverage/lcov-report/index.html"
}

# Option 7: Build the Docker image for the application
build_docker_image() {
    info "Building Docker image '${DOCKER_IMAGE}'..."
    cd "$PROJECT_ROOT"
    docker build -t "$DOCKER_IMAGE" .
    success "Docker image '${DOCKER_IMAGE}' built successfully."
}

# Option 8: Run the full stack with Docker Compose
run_docker_compose() {
    info "Starting all services with Docker Compose..."
    cd "$PROJECT_ROOT"
    docker-compose up
}

# Option 9: Lint the source code
lint_code() {
    info "Running ESLint..."
    cd "$PROJECT_ROOT"
    npm run lint
    success "Linting complete."
}

# Option 10: View application container logs
view_logs() {
    info "Fetching application container logs..."
    cd "$PROJECT_ROOT"
    docker-compose logs -f app
}

# Option 11: Stop all Docker Compose containers
stop_containers() {
    info "Stopping all Docker Compose containers..."
    cd "$PROJECT_ROOT"
    docker-compose down
    success "All containers stopped."
}

# Option 12: Clean build artifacts and dependencies
clean_build() {
    info "Cleaning build artifacts and node_modules..."
    cd "$PROJECT_ROOT"
    rm -rf dist node_modules
    success "Cleaned dist/ and node_modules/."
}

# ---------------------------------------------------------------------------
# Main menu loop
# ---------------------------------------------------------------------------

main() {
    # Verify prerequisites once at startup
    check_prerequisites || exit 1

    while true; do
        print_header

        echo -e "${BOLD}Select an operation:${NC}"
        echo ""
        echo "   1) Start Keycloak (docker-compose up keycloak)"
        echo "   2) Install dependencies (npm ci)"
        echo "   3) Run application (npm run start:dev)"
        echo "   4) Run unit tests (npm test)"
        echo "   5) Run e2e tests (npm run test:e2e)"
        echo "   6) Generate coverage report (npm run test:cov)"
        echo "   7) Build Docker image (docker build)"
        echo "   8) Run with Docker Compose (docker-compose up)"
        echo "   9) Lint code (npm run lint)"
        echo "  10) View application logs (docker logs)"
        echo "  11) Stop all containers (docker-compose down)"
        echo "  12) Clean (rm -rf dist node_modules)"
        echo "   0) Exit"
        echo ""

        read -rp "Enter your choice [0-12]: " choice

        case $choice in
            1)  start_keycloak ;;
            2)  install_dependencies ;;
            3)  run_application ;;
            4)  run_unit_tests ;;
            5)  run_e2e_tests ;;
            6)  generate_coverage ;;
            7)  build_docker_image ;;
            8)  run_docker_compose ;;
            9)  lint_code ;;
            10) view_logs ;;
            11) stop_containers ;;
            12) clean_build ;;
            0)
                info "Exiting. Goodbye."
                exit 0
                ;;
            *)
                warn "Invalid option: $choice"
                ;;
        esac

        pause
    done
}

# Entry point
main "$@"
