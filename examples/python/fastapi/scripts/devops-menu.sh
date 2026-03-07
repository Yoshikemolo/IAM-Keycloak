#!/usr/bin/env bash
#
# devops-menu.sh -- Interactive DevOps Menu for FastAPI IAM Resource Server
#
# This script provides a numbered menu of common development and operations
# tasks for the FastAPI IAM example project. It wraps Python, pip, uvicorn,
# Docker, and Docker Compose commands so that developers can perform routine
# tasks without memorizing individual commands.
#
# Usage:
#   ./scripts/devops-menu.sh
#
# Prerequisites:
#   - Python 3.12+
#   - pip (or Poetry)
#   - Docker 24+ and Docker Compose 2.x
#
# The script must be run from the project root directory (examples/python/fastapi).
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Project name displayed in the menu header
PROJECT_NAME="FastAPI IAM Resource Server"

# Docker image name for the application
DOCKER_IMAGE="iam-fastapi"

# Virtual environment directory
VENV_DIR=".venv"

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

    # Check for python3 or python
    if ! check_command python3 && ! check_command python; then
        missing=1
    fi

    if ! check_command pip3 && ! check_command pip; then
        warn "pip is not found. You may need it for dependency installation."
    fi

    if ! check_command docker; then missing=1; fi

    if [[ $missing -eq 1 ]]; then
        error "Some prerequisites are missing. Please install them before continuing."
        return 1
    fi

    success "All prerequisites satisfied."
}

# Get the Python executable (prefer python3)
get_python() {
    if command -v python3 &> /dev/null; then
        echo "python3"
    else
        echo "python"
    fi
}

# Get the pip executable (prefer pip3)
get_pip() {
    if command -v pip3 &> /dev/null; then
        echo "pip3"
    else
        echo "pip"
    fi
}

# Activate the virtual environment if it exists
activate_venv() {
    local venv_path="$PROJECT_ROOT/$VENV_DIR"
    if [[ -d "$venv_path" ]]; then
        # shellcheck disable=SC1091
        source "$venv_path/bin/activate" 2>/dev/null || source "$venv_path/Scripts/activate" 2>/dev/null
        info "Virtual environment activated."
    else
        warn "Virtual environment not found at $venv_path. Some commands may fail."
        warn "Run option 2 to create a virtual environment first."
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

# Option 2: Create a Python virtual environment
create_venv() {
    local python_cmd
    python_cmd=$(get_python)
    info "Creating virtual environment at $VENV_DIR..."
    cd "$PROJECT_ROOT"
    $python_cmd -m venv "$VENV_DIR"
    success "Virtual environment created at $VENV_DIR."
    info "Activate it with: source $VENV_DIR/bin/activate"
}

# Option 3: Install project dependencies
install_dependencies() {
    info "Installing dependencies..."
    cd "$PROJECT_ROOT"
    activate_venv
    if [[ -f "requirements.txt" ]]; then
        pip install -r requirements.txt
    elif [[ -f "pyproject.toml" ]] && command -v poetry &> /dev/null; then
        poetry install
    else
        error "No requirements.txt or pyproject.toml found."
        return 1
    fi
    success "Dependencies installed."
}

# Option 4: Run the FastAPI application with uvicorn
run_application() {
    info "Starting the FastAPI application..."
    cd "$PROJECT_ROOT"
    activate_venv
    uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
}

# Option 5: Run tests with pytest
run_tests() {
    info "Running tests with pytest..."
    cd "$PROJECT_ROOT"
    activate_venv
    pytest
    success "Tests complete."
}

# Option 6: Run tests with code coverage
run_tests_coverage() {
    info "Running tests with coverage..."
    cd "$PROJECT_ROOT"
    activate_venv
    pytest --cov=app --cov-report=html --cov-report=term
    success "Coverage report generated at htmlcov/index.html"
}

# Option 7: Generate OpenAPI specification to a JSON file
generate_openapi() {
    info "Generating OpenAPI specification..."
    cd "$PROJECT_ROOT"
    activate_venv
    python -c "
import json
from app.main import app
spec = app.openapi()
with open('openapi.json', 'w') as f:
    json.dump(spec, f, indent=2)
print('OpenAPI spec written to openapi.json')
"
    success "OpenAPI specification saved to openapi.json"
}

# Option 8: Build the Docker image for the application
build_docker_image() {
    info "Building Docker image '${DOCKER_IMAGE}'..."
    cd "$PROJECT_ROOT"
    docker build -t "$DOCKER_IMAGE" .
    success "Docker image '${DOCKER_IMAGE}' built successfully."
}

# Option 9: Run the full stack with Docker Compose
run_docker_compose() {
    info "Starting all services with Docker Compose..."
    cd "$PROJECT_ROOT"
    docker-compose up
}

# Option 10: Lint the source code with ruff
lint_code() {
    info "Running ruff linter..."
    cd "$PROJECT_ROOT"
    activate_venv
    ruff check app tests
    success "Linting complete."
}

# Option 11: Format the source code with ruff
format_code() {
    info "Formatting code with ruff..."
    cd "$PROJECT_ROOT"
    activate_venv
    ruff format app tests
    success "Code formatting applied."
}

# Option 12: Run type checking with mypy
type_check() {
    info "Running mypy type checker..."
    cd "$PROJECT_ROOT"
    activate_venv
    mypy app
    success "Type checking complete."
}

# Option 13: View application container logs
view_logs() {
    info "Fetching application container logs..."
    cd "$PROJECT_ROOT"
    docker-compose logs -f app
}

# Option 14: Stop all Docker Compose containers
stop_containers() {
    info "Stopping all Docker Compose containers..."
    cd "$PROJECT_ROOT"
    docker-compose down
    success "All containers stopped."
}

# Option 15: Clean build artifacts and virtual environment
clean_build() {
    info "Cleaning build artifacts..."
    cd "$PROJECT_ROOT"
    rm -rf __pycache__ .pytest_cache htmlcov .mypy_cache .ruff_cache
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true

    read -rp "Also remove virtual environment ($VENV_DIR)? [y/N]: " remove_venv
    if [[ "$remove_venv" =~ ^[Yy]$ ]]; then
        rm -rf "$VENV_DIR"
        success "Virtual environment removed."
    fi

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
        echo "   2) Create virtual environment (python -m venv)"
        echo "   3) Install dependencies (pip install -r requirements.txt)"
        echo "   4) Run application (uvicorn app.main:app --reload)"
        echo "   5) Run tests (pytest)"
        echo "   6) Run tests with coverage (pytest --cov)"
        echo "   7) Generate OpenAPI spec (openapi.json)"
        echo "   8) Build Docker image (docker build)"
        echo "   9) Run with Docker Compose (docker-compose up)"
        echo "  10) Lint code (ruff check)"
        echo "  11) Format code (ruff format)"
        echo "  12) Type check (mypy)"
        echo "  13) View application logs (docker logs)"
        echo "  14) Stop all containers (docker-compose down)"
        echo "  15) Clean build artifacts"
        echo "   0) Exit"
        echo ""

        read -rp "Enter your choice [0-15]: " choice

        case $choice in
            1)  start_keycloak ;;
            2)  create_venv ;;
            3)  install_dependencies ;;
            4)  run_application ;;
            5)  run_tests ;;
            6)  run_tests_coverage ;;
            7)  generate_openapi ;;
            8)  build_docker_image ;;
            9)  run_docker_compose ;;
            10) lint_code ;;
            11) format_code ;;
            12) type_check ;;
            13) view_logs ;;
            14) stop_containers ;;
            15) clean_build ;;
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
