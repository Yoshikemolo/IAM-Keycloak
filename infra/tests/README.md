# Infrastructure Tests

## Description

This document describes how to validate the infrastructure code used in this project. All infrastructure components -- Terraform configurations, Kubernetes manifests, Helm charts, and Docker images -- should be verified before deployment to any environment.

Automated validation ensures that misconfigurations are caught early, security policies are enforced, and deployments remain predictable across environments.

---

## Testing Tools

### Terraform

| Tool | Purpose | Command |
|------|---------|---------|
| `terraform validate` | Syntax and internal consistency check | `terraform validate` |
| `terraform plan` | Preview changes before applying | `terraform plan -var-file=env/<env>.tfvars` |
| `tflint` | Linting for Terraform best practices | `tflint --recursive` |
| `checkov` | Static analysis for security and compliance | `checkov -d .` |

### Kubernetes

| Tool | Purpose | Command |
|------|---------|---------|
| `kubectl --dry-run` | Validate manifests against the API server | `kubectl apply -f manifest.yaml --dry-run=server` |
| `kubeconform` | Offline schema validation of K8s manifests | `kubeconform -strict base/` |
| `kustomize build` | Validate kustomize overlays | `kustomize build overlays/dev \| kubeconform` |

### Helm

| Tool | Purpose | Command |
|------|---------|---------|
| `helm lint` | Check chart structure and values | `helm lint ./charts/*` |
| `helm template` | Render templates and validate output | `helm template ./charts/myapp \| kubeconform` |

### Docker

| Tool | Purpose | Command |
|------|---------|---------|
| `hadolint` | Lint Dockerfiles for best practices | `hadolint Dockerfile` |
| `trivy image` | Scan container images for vulnerabilities | `trivy image <image-name>:<tag>` |

---

## Verification Checklist

| Test | Command | Expected Result |
|------|---------|-----------------|
| Terraform format | `terraform fmt -check` | No formatting changes |
| Terraform validate | `terraform validate` | Success |
| TFLint | `tflint` | No errors |
| Checkov IaC scan | `checkov -d .` | No HIGH/CRITICAL findings |
| Helm lint | `helm lint ./charts/*` | No errors |
| K8s manifest validation | `kubeconform base/` | Valid schemas |
| Docker lint | `hadolint Dockerfile` | No warnings |
| Container scan | `trivy image <name>` | No CRITICAL vulnerabilities |

---

## CI Integration Notes

All of the checks listed above should be integrated into the CI pipeline to enforce quality gates on every pull request.

### Recommended Pipeline Stages

1. **Lint** -- Run `terraform fmt -check`, `tflint`, `hadolint`, and `helm lint` to catch formatting and style issues early.
2. **Validate** -- Run `terraform validate`, `kubeconform`, and `kustomize build | kubeconform` to verify structural correctness.
3. **Security Scan** -- Run `checkov -d .` and `trivy image` to detect security misconfigurations and known vulnerabilities.
4. **Plan / Dry-Run** -- Run `terraform plan` and `kubectl apply --dry-run=server` to preview changes before they are applied.

### Guidelines

- **Fail the pipeline** if any HIGH or CRITICAL findings are reported by Checkov or Trivy.
- **Terraform plan output** should be saved as a pipeline artifact for review before `terraform apply`.
- Use **environment-specific variable files** (`env/dev.tfvars`, `env/qa.tfvars`, `env/prod.tfvars`) to ensure plans are generated against the correct environment.
- Pin tool versions in CI to avoid unexpected behavior from upstream updates.
- Store Terraform state remotely (e.g., Azure Storage, AWS S3) and enable state locking to prevent concurrent modifications.
