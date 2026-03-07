# DevOps

This folder contains deployment automation scripts and tooling for the IAM platform and all example applications.

## Structure

```
devops/
├── README.md                  # This file
├── quick-start.sh             # Interactive launcher for deploying any project
├── docker-compose.base.yml    # Shared services (Keycloak, PostgreSQL, observability)
├── .env.dev                   # Environment variables for dev
├── .env.qa                    # Environment variables for QA
├── .env.prod                  # Environment variables for prod (secrets via K8s)
└── scripts/                   # Auxiliary deployment scripts
```

## Quick Start

The `quick-start.sh` script provides an interactive menu to deploy any combination of infrastructure, Keycloak, and example applications as Docker containers.

```bash
./devops/quick-start.sh
```

## Design Principles

- Every project includes its own `Dockerfile` and `docker-compose.yml`
- All containers include health checks
- All containers use explicit names for easy identification
- Environment variables are externalized via `.env` files
- Secrets are managed via Kubernetes Secrets in non-local environments
- All images follow container hardening best practices (non-root, read-only rootfs, minimal base)

## Related Documentation

- [Infrastructure as Code](../doc/05-infrastructure-as-code.md)
- [CI/CD Pipelines](../doc/06-cicd-pipelines.md)
- [Environment Management](../doc/12-environment-management.md)
- [Automation and Scripts](../doc/13-automation-scripts.md)
