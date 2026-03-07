# Infrastructure

This folder contains all infrastructure-related code and configuration for deploying and managing the IAM platform.

## Structure

```
infra/
├── terraform/               # Infrastructure as Code
│   ├── modules/             # Reusable Terraform modules
│   │   ├── kubernetes-cluster/
│   │   ├── keycloak/
│   │   ├── postgresql/
│   │   ├── networking/
│   │   └── observability/
│   └── environments/        # Per-environment configurations
│       ├── dev/
│       ├── qa/
│       └── prod/
├── kubernetes/              # Kubernetes manifests (Kustomize)
│   ├── base/                # Base resources shared across environments
│   └── overlays/            # Environment-specific patches
│       ├── dev/
│       ├── qa/
│       └── prod/
├── helm/                    # Helm chart values
│   └── values/              # Per-environment values files
├── docker/                  # Shared Dockerfiles and compose files
└── scripts/                 # Infrastructure automation scripts
```

## Related Documentation

- [Infrastructure as Code](../doc/05-infrastructure-as-code.md)
- [CI/CD Pipelines](../doc/06-cicd-pipelines.md)
- [Environment Management](../doc/12-environment-management.md)
- [Automation and Scripts](../doc/13-automation-scripts.md)
