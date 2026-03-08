# Contributing to IAM-Keycloak

Thank you for your interest in contributing to this project. This document
provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Commit Messages](#commit-messages)
- [Pull Requests](#pull-requests)
- [Coding Standards](#coding-standards)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code.

## Getting Started

1. Fork the repository.
2. Clone your fork locally.
3. Create a feature branch from `dev`:
   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b feature/your-feature-name
   ```
4. Make your changes.
5. Push to your fork and open a Pull Request against `dev`.

### Prerequisites

- **Docker** and **Docker Compose** for running Keycloak locally.
- **Java 17+** for Keycloak SPI providers and Spring Boot / Quarkus examples.
- **Node.js 22+** for frontend examples and NestJS / Express backends.
- **Python 3.12+** for the FastAPI example.
- **.NET 9 SDK** for the ASP.NET Core example.
- **Terraform 1.9+** for infrastructure modules.
- **kubectl** and **Helm 3** for Kubernetes deployments.

## Development Workflow

This project follows **Gitflow**:

- `main` -- production-ready releases.
- `dev` -- integration branch for the next release.
- `feature/*` -- new features branch off `dev`.
- `fix/*` -- bug fixes branch off `dev`.
- `hotfix/*` -- urgent fixes branch off `main`.

All Pull Requests target `dev` unless they are hotfixes.

## Commit Messages

We use **Conventional Commits**:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

| Type       | Description                                  |
|------------|----------------------------------------------|
| `feat`     | A new feature                                |
| `fix`      | A bug fix                                    |
| `docs`     | Documentation changes only                   |
| `style`    | Formatting, missing semicolons, etc.         |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test`     | Adding or updating tests                     |
| `chore`    | Build process, tooling, or auxiliary changes |
| `ci`       | CI/CD pipeline changes                       |
| `perf`     | Performance improvements                     |

### Scopes

Common scopes: `keycloak`, `infra`, `frontend`, `backend`, `cicd`, `docs`.

### Examples

```
feat(keycloak): add custom audit event listener SPI
fix(frontend): resolve theme toggle not persisting on reload
docs: update architecture diagram with multi-region failover
test(backend): add Testcontainers integration test for Spring Boot
```

## Pull Requests

- Keep PRs focused and small. One concern per PR.
- Fill out the PR template completely.
- Ensure all CI checks pass before requesting review.
- Link related issues in the PR description.
- Squash commits if the history is noisy; keep meaningful commits if they tell a story.

## Coding Standards

### General

- Write clean, readable, self-documenting code.
- Add documentation comments on all public classes, methods, and interfaces.
- Follow each language's idiomatic conventions.
- Do not commit secrets, credentials, or environment-specific values.

### Language-Specific

| Language   | Style Guide                              | Documentation    |
|------------|------------------------------------------|------------------|
| Java 17    | Google Java Style                        | JavaDoc          |
| TypeScript | ESLint + Prettier                        | TSDoc / JSDoc    |
| Python     | PEP 8 + Black formatter                  | Google docstrings|
| C#         | .NET coding conventions                  | XML doc comments |
| HCL        | `terraform fmt`                          | Inline comments  |
| Shell      | ShellCheck                               | Header comments  |

### Testing

- Write unit tests for all business logic.
- Write integration tests for auth flows and API endpoints.
- Aim for meaningful coverage, not just high numbers.

## Reporting Issues

- Use the [Bug Report](https://github.com/Yoshikemolo/IAM-Keycloak/issues/new?template=bug_report.yml) template for bugs.
- Use the [Feature Request](https://github.com/Yoshikemolo/IAM-Keycloak/issues/new?template=feature_request.yml) template for enhancements.
- Search existing issues before creating a new one.
- Provide as much context as possible: steps to reproduce, environment, logs, screenshots.

---

Thank you for helping improve this project.
