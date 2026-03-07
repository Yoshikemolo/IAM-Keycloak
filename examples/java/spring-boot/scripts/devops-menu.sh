#!/usr/bin/env bash
#
# devops-menu.sh -- Interactive DevOps Menu for Spring Boot IAM Resource Server
#
# This script provides a numbered menu of common development and operations
# tasks for the Spring Boot IAM example project. It wraps Gradle, Docker,
# and Docker Compose commands so that developers can perform routine tasks
# without memorizing individual commands.
#
# Usage:
#   ./scripts/devops-menu.sh
#
# Prerequisites:
#   - Java 17+
#   - Gradle 8.x (wrapper included in project)
#   - Docker 24+ and Docker Compose 2.x
#
# The script must be run from the project root directory (examples/java/spring-boot).
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Project name displayed in the menu header
PROJECT_NAME="Spring Boot IAM Resource Server"

# Docker image name for the application
DOCKER_IMAGE="iam-spring-boot"

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

    if ! check_command java; then missing=1; fi
    if ! check_command docker; then missing=1; fi

    # Check for Gradle wrapper or system Gradle
    if [[ ! -f "$PROJECT_ROOT/gradlew" ]] && ! command -v gradle &> /dev/null; then
        error "Gradle wrapper (gradlew) not found and gradle is not in PATH."
        missing=1
    fi

    if [[ $missing -eq 1 ]]; then
        error "Some prerequisites are missing. Please install them before continuing."
        return 1
    fi

    success "All prerequisites satisfied."
}

# Run a Gradle command using the wrapper if available, otherwise system Gradle
run_gradle() {
    cd "$PROJECT_ROOT"
    if [[ -f "./gradlew" ]]; then
        ./gradlew "$@"
    else
        gradle "$@"
    fi
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

# Option 2: Run the Spring Boot application
run_application() {
    info "Starting the Spring Boot application..."
    run_gradle bootRun
}

# Option 3: Run unit tests
run_unit_tests() {
    info "Running unit tests..."
    run_gradle test
    success "Unit tests complete. See build/reports/tests/test/index.html for results."
}

# Option 4: Run integration tests (requires Docker for Testcontainers)
run_integration_tests() {
    info "Running integration tests (Testcontainers + Keycloak)..."
    run_gradle integrationTest
    success "Integration tests complete."
}

# Option 5: Generate JaCoCo code coverage report
generate_coverage() {
    info "Generating JaCoCo code coverage report..."
    run_gradle jacocoTestReport
    success "Coverage report generated at build/reports/jacoco/test/html/index.html"
}

# Option 6: Build the Docker image for the application
build_docker_image() {
    info "Building Docker image '${DOCKER_IMAGE}'..."
    cd "$PROJECT_ROOT"
    docker build -t "$DOCKER_IMAGE" .
    success "Docker image '${DOCKER_IMAGE}' built successfully."
}

# Option 7: Run the full stack with Docker Compose
run_docker_compose() {
    info "Starting all services with Docker Compose..."
    cd "$PROJECT_ROOT"
    docker-compose up
}

# Option 8: Lint and format the source code using Spotless
lint_and_format() {
    info "Running Spotless code formatter..."
    run_gradle spotlessApply
    success "Code formatting applied."
}

# Option 9: Check dependencies for known vulnerabilities
check_vulnerabilities() {
    info "Analyzing dependencies for vulnerabilities..."
    run_gradle dependencyCheckAnalyze
    success "Vulnerability report generated. Check build/reports/dependency-check-report.html"
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

# Option 12: Clean build artifacts
clean_build() {
    info "Cleaning build artifacts..."
    run_gradle clean
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
        echo "   2) Run application (./gradlew bootRun)"
        echo "   3) Run unit tests (./gradlew test)"
        echo "   4) Run integration tests (./gradlew integrationTest)"
        echo "   5) Generate coverage report (./gradlew jacocoTestReport)"
        echo "   6) Build Docker image (docker build)"
        echo "   7) Run with Docker Compose (docker-compose up)"
        echo "   8) Lint and format (./gradlew spotlessApply)"
        echo "   9) Check dependencies for vulnerabilities"
        echo "  10) View application logs (docker logs)"
        echo "  11) Stop all containers (docker-compose down)"
        echo "  12) Clean build artifacts (./gradlew clean)"
        echo "   0) Exit"
        echo ""

        read -rp "Enter your choice [0-12]: " choice

        case $choice in
            1)  start_keycloak ;;
            2)  run_application ;;
            3)  run_unit_tests ;;
            4)  run_integration_tests ;;
            5)  generate_coverage ;;
            6)  build_docker_image ;;
            7)  run_docker_compose ;;
            8)  lint_and_format ;;
            9)  check_vulnerabilities ;;
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
