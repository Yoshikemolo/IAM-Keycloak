#!/usr/bin/env bash
#
# devops-menu.sh -- Interactive DevOps Menu for ASP.NET Core IAM Resource Server
#
# This script provides a numbered menu of common development and operations
# tasks for the .NET IAM example project. It wraps dotnet CLI, Docker, and
# Docker Compose commands so that developers can perform routine tasks
# without memorizing individual commands.
#
# Usage:
#   ./scripts/devops-menu.sh
#
# Prerequisites:
#   - .NET 9 SDK
#   - Docker 24+ and Docker Compose 2.x
#
# The script must be run from the project root directory (examples/dotnet).
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Project name displayed in the menu header
PROJECT_NAME="ASP.NET Core IAM Resource Server"

# Docker image name for the application
DOCKER_IMAGE="iam-dotnet"

# Docker Compose file location (relative to project root)
COMPOSE_FILE="docker-compose.yml"

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

    if ! check_command dotnet; then missing=1; fi
    if ! check_command docker; then missing=1; fi

    if [[ $missing -eq 1 ]]; then
        error "Some prerequisites are missing. Please install them before continuing."
        return 1
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

# Option 2: Run the .NET application
run_application() {
    info "Starting the ASP.NET Core application..."
    cd "$PROJECT_ROOT/src"
    dotnet run
}

# Option 3: Run all tests
run_tests() {
    info "Running all tests..."
    cd "$PROJECT_ROOT"
    dotnet test
    success "Tests complete."
}

# Option 4: Run tests with code coverage collection
run_tests_coverage() {
    info "Running tests with code coverage..."
    cd "$PROJECT_ROOT"
    dotnet test --collect:"XPlat Code Coverage"
    success "Tests complete. Coverage data written to tests/TestResults/."
}

# Option 5: Build the Docker image for the application
build_docker_image() {
    info "Building Docker image '${DOCKER_IMAGE}'..."
    cd "$PROJECT_ROOT"
    docker build -t "$DOCKER_IMAGE" .
    success "Docker image '${DOCKER_IMAGE}' built successfully."
}

# Option 6: Run the full stack with Docker Compose
run_docker_compose() {
    info "Starting all services with Docker Compose..."
    cd "$PROJECT_ROOT"
    docker-compose up
}

# Option 7: Format the source code using dotnet format
format_code() {
    info "Formatting code with dotnet format..."
    cd "$PROJECT_ROOT"
    dotnet format
    success "Code formatting applied."
}

# Option 8: Check NuGet packages for known vulnerabilities
check_vulnerabilities() {
    info "Checking NuGet packages for known vulnerabilities..."
    cd "$PROJECT_ROOT"
    dotnet list package --vulnerable
    success "Vulnerability check complete."
}

# Option 9: View application container logs
view_logs() {
    info "Fetching application container logs..."
    cd "$PROJECT_ROOT"
    docker-compose logs -f app
}

# Option 10: Stop all Docker Compose containers
stop_containers() {
    info "Stopping all Docker Compose containers..."
    cd "$PROJECT_ROOT"
    docker-compose down
    success "All containers stopped."
}

# Option 11: Clean build artifacts
clean_build() {
    info "Cleaning build artifacts..."
    cd "$PROJECT_ROOT"
    dotnet clean
    success "Build artifacts cleaned."
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
        echo "   2) Run application (dotnet run)"
        echo "   3) Run tests (dotnet test)"
        echo "   4) Run tests with coverage (dotnet test --collect)"
        echo "   5) Build Docker image (docker build)"
        echo "   6) Run with Docker Compose (docker-compose up)"
        echo "   7) Format code (dotnet format)"
        echo "   8) Check vulnerabilities (dotnet list package --vulnerable)"
        echo "   9) View application logs (docker logs)"
        echo "  10) Stop all containers (docker-compose down)"
        echo "  11) Clean build artifacts (dotnet clean)"
        echo "   0) Exit"
        echo ""

        read -rp "Enter your choice [0-11]: " choice

        case $choice in
            1)  start_keycloak ;;
            2)  run_application ;;
            3)  run_tests ;;
            4)  run_tests_coverage ;;
            5)  build_docker_image ;;
            6)  run_docker_compose ;;
            7)  format_code ;;
            8)  check_vulnerabilities ;;
            9)  view_logs ;;
            10) stop_containers ;;
            11) clean_build ;;
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
