#!/usr/bin/env bash
###############################################################################
# Infrastructure DevOps Menu
# Interactive menu for infrastructure validation, deployment, and operations.
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
INFRA_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TERRAFORM_DIR="${INFRA_ROOT}/terraform"
K8S_DIR="${INFRA_ROOT}/k8s"
CHARTS_DIR="${INFRA_ROOT}/charts"

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------
print_header() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "============================================================"
    echo "  Infrastructure DevOps Menu"
    echo "============================================================"
    echo -e "${NC}"
    echo -e "  ${CYAN}Project root:${NC} ${INFRA_ROOT}"
    echo -e "  ${CYAN}Date:${NC}         $(date '+%Y-%m-%d %H:%M:%S')"
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

check_prerequisites() {
    local tool="$1"
    case "${tool}" in
        terraform)  check_command terraform ;;
        tflint)     check_command tflint ;;
        checkov)    check_command checkov ;;
        kustomize)  check_command kustomize ;;
        kubeconform) check_command kubeconform ;;
        helm)       check_command helm ;;
        trivy)      check_command trivy ;;
        hadolint)   check_command hadolint ;;
        kubectl)    check_command kubectl ;;
        *)          return 0 ;;
    esac
}

# ---------------------------------------------------------------------------
# Environment selector
# ---------------------------------------------------------------------------
select_environment() {
    echo -e "${BOLD}Select environment:${NC}"
    echo "  1) dev"
    echo "  2) qa"
    echo "  3) prod"
    echo ""
    read -rp "Environment [1-3]: " env_choice
    case "${env_choice}" in
        1) SELECTED_ENV="dev" ;;
        2) SELECTED_ENV="qa" ;;
        3) SELECTED_ENV="prod" ;;
        *)
            print_error "Invalid selection."
            return 1
            ;;
    esac
    print_info "Selected environment: ${SELECTED_ENV}"
}

# ---------------------------------------------------------------------------
# Menu actions
# ---------------------------------------------------------------------------

terraform_init() {
    check_prerequisites terraform || return
    select_environment || return
    print_info "Running terraform init for environment: ${SELECTED_ENV}"
    terraform -chdir="${TERRAFORM_DIR}" init \
        -backend-config="env/${SELECTED_ENV}/backend.tfvars"
}

terraform_plan() {
    check_prerequisites terraform || return
    select_environment || return
    print_info "Running terraform plan for environment: ${SELECTED_ENV}"
    terraform -chdir="${TERRAFORM_DIR}" plan \
        -var-file="env/${SELECTED_ENV}.tfvars"
}

terraform_apply() {
    check_prerequisites terraform || return
    select_environment || return
    if [[ "${SELECTED_ENV}" == "prod" ]]; then
        echo ""
        print_warn "You are about to apply changes to PRODUCTION."
        read -rp "Type 'yes' to confirm: " confirm
        if [[ "${confirm}" != "yes" ]]; then
            print_info "Aborted."
            return
        fi
    fi
    print_info "Running terraform apply for environment: ${SELECTED_ENV}"
    terraform -chdir="${TERRAFORM_DIR}" apply \
        -var-file="env/${SELECTED_ENV}.tfvars"
}

terraform_destroy() {
    check_prerequisites terraform || return
    select_environment || return
    echo ""
    print_warn "WARNING: This will DESTROY all resources in '${SELECTED_ENV}'."
    read -rp "Type the environment name to confirm: " confirm
    if [[ "${confirm}" != "${SELECTED_ENV}" ]]; then
        print_info "Aborted. Confirmation did not match."
        return
    fi
    print_info "Running terraform destroy for environment: ${SELECTED_ENV}"
    terraform -chdir="${TERRAFORM_DIR}" destroy \
        -var-file="env/${SELECTED_ENV}.tfvars"
}

terraform_fmt_check() {
    check_prerequisites terraform || return
    print_info "Checking Terraform formatting..."
    terraform -chdir="${TERRAFORM_DIR}" fmt -check -recursive
    print_success "Terraform format check passed."
}

terraform_validate() {
    check_prerequisites terraform || return
    print_info "Validating Terraform configuration..."
    terraform -chdir="${TERRAFORM_DIR}" validate
    print_success "Terraform validation passed."
}

run_tflint() {
    check_prerequisites tflint || return
    print_info "Running TFLint..."
    (cd "${TERRAFORM_DIR}" && tflint --recursive)
    print_success "TFLint completed."
}

run_checkov() {
    check_prerequisites checkov || return
    print_info "Running Checkov security scan..."
    checkov -d "${TERRAFORM_DIR}" --compact
    print_success "Checkov scan completed."
}

kustomize_build() {
    check_prerequisites kustomize || return
    echo -e "${BOLD}Select overlay:${NC}"
    echo "  1) dev"
    echo "  2) qa"
    echo "  3) prod"
    echo ""
    read -rp "Overlay [1-3]: " overlay_choice
    case "${overlay_choice}" in
        1) OVERLAY="dev" ;;
        2) OVERLAY="qa" ;;
        3) OVERLAY="prod" ;;
        *)
            print_error "Invalid selection."
            return
            ;;
    esac
    print_info "Building kustomize overlay: ${OVERLAY}"
    kustomize build "${K8S_DIR}/overlays/${OVERLAY}"
    print_success "Kustomize build completed for overlay: ${OVERLAY}"
}

validate_k8s_manifests() {
    check_prerequisites kubeconform || return
    print_info "Validating Kubernetes manifests..."
    kubeconform -strict "${K8S_DIR}/base/"
    print_success "Kubernetes manifest validation passed."
}

helm_lint() {
    check_prerequisites helm || return
    print_info "Linting Helm charts..."
    for chart_dir in "${CHARTS_DIR}"/*/; do
        if [[ -f "${chart_dir}/Chart.yaml" ]]; then
            print_info "Linting: ${chart_dir}"
            helm lint "${chart_dir}"
        fi
    done
    print_success "Helm lint completed."
}

helm_template() {
    check_prerequisites helm || return
    echo -e "${BOLD}Available charts:${NC}"
    local i=1
    local charts=()
    for chart_dir in "${CHARTS_DIR}"/*/; do
        if [[ -f "${chart_dir}/Chart.yaml" ]]; then
            charts+=("${chart_dir}")
            echo "  ${i}) $(basename "${chart_dir}")"
            ((i++))
        fi
    done
    if [[ ${#charts[@]} -eq 0 ]]; then
        print_warn "No Helm charts found in ${CHARTS_DIR}."
        return
    fi
    echo ""
    read -rp "Select chart [1-${#charts[@]}]: " chart_choice
    local idx=$((chart_choice - 1))
    if [[ ${idx} -lt 0 || ${idx} -ge ${#charts[@]} ]]; then
        print_error "Invalid selection."
        return
    fi
    print_info "Rendering Helm template (dry-run): ${charts[${idx}]}"
    helm template "$(basename "${charts[${idx}]}")" "${charts[${idx}]}"
    print_success "Helm template rendering completed."
}

scan_docker_images() {
    check_prerequisites trivy || return
    echo ""
    read -rp "Enter image name (e.g., myapp:latest): " image_name
    if [[ -z "${image_name}" ]]; then
        print_error "No image name provided."
        return
    fi
    print_info "Scanning Docker image: ${image_name}"
    trivy image "${image_name}"
    print_success "Trivy scan completed."
}

lint_dockerfiles() {
    check_prerequisites hadolint || return
    print_info "Searching for Dockerfiles..."
    local found=0
    while IFS= read -r -d '' dockerfile; do
        print_info "Linting: ${dockerfile}"
        hadolint "${dockerfile}"
        found=1
    done < <(find "${INFRA_ROOT}" -name "Dockerfile*" -print0 2>/dev/null)
    if [[ ${found} -eq 0 ]]; then
        print_warn "No Dockerfiles found under ${INFRA_ROOT}."
    else
        print_success "Dockerfile linting completed."
    fi
}

view_cluster_status() {
    check_prerequisites kubectl || return
    print_info "Fetching pod status across all namespaces..."
    kubectl get pods -A
}

view_cluster_logs() {
    check_prerequisites kubectl || return
    echo ""
    read -rp "Namespace [default]: " ns
    ns="${ns:-default}"
    echo ""
    kubectl get pods -n "${ns}" --no-headers 2>/dev/null | awk '{print NR") "$1}'
    echo ""
    read -rp "Enter pod name: " pod_name
    if [[ -z "${pod_name}" ]]; then
        print_error "No pod name provided."
        return
    fi
    read -rp "Tail lines [100]: " tail_lines
    tail_lines="${tail_lines:-100}"
    print_info "Fetching logs for pod '${pod_name}' in namespace '${ns}'..."
    kubectl logs -n "${ns}" "${pod_name}" --tail="${tail_lines}"
}

# ---------------------------------------------------------------------------
# Main menu loop
# ---------------------------------------------------------------------------
main() {
    while true; do
        print_header
        echo -e "${BOLD}  Terraform${NC}"
        echo "    1) Terraform init (select environment)"
        echo "    2) Terraform plan"
        echo "    3) Terraform apply"
        echo "    4) Terraform destroy (with confirmation)"
        echo "    5) Terraform format check"
        echo "    6) Terraform validate"
        echo ""
        echo -e "${BOLD}  Linting and Security${NC}"
        echo "    7) Run TFLint"
        echo "    8) Run Checkov scan"
        echo ""
        echo -e "${BOLD}  Kubernetes${NC}"
        echo "    9) Kustomize build (select overlay)"
        echo "   10) Validate K8s manifests (kubeconform)"
        echo ""
        echo -e "${BOLD}  Helm${NC}"
        echo "   11) Helm lint"
        echo "   12) Helm template (dry-run)"
        echo ""
        echo -e "${BOLD}  Docker${NC}"
        echo "   13) Scan Docker images (Trivy)"
        echo "   14) Lint Dockerfiles (Hadolint)"
        echo ""
        echo -e "${BOLD}  Cluster${NC}"
        echo "   15) View cluster status (kubectl get pods -A)"
        echo "   16) View cluster logs (kubectl logs)"
        echo ""
        echo -e "    ${RED}0) Exit${NC}"
        echo ""
        read -rp "Select an option [0-16]: " choice

        case "${choice}" in
            1)  terraform_init ;;
            2)  terraform_plan ;;
            3)  terraform_apply ;;
            4)  terraform_destroy ;;
            5)  terraform_fmt_check ;;
            6)  terraform_validate ;;
            7)  run_tflint ;;
            8)  run_checkov ;;
            9)  kustomize_build ;;
            10) validate_k8s_manifests ;;
            11) helm_lint ;;
            12) helm_template ;;
            13) scan_docker_images ;;
            14) lint_dockerfiles ;;
            15) view_cluster_status ;;
            16) view_cluster_logs ;;
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
