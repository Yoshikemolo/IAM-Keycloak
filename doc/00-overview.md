# Enterprise IAM Platform - Keycloak Multi-Tenant Infrastructure

## Executive Summary

This document serves as the primary index and overview for the Enterprise Identity and Access Management (IAM) platform built on Keycloak. The project delivers a production-grade, multi-tenant IAM infrastructure designed from scratch using Keycloak and modern DevOps tooling.

The platform provides centralized authentication, authorization, and identity federation for multiple tenants, with each tenant isolated within its own Keycloak Realm. The solution is built on Kubernetes, fully automated through Infrastructure as Code, and instrumented with a comprehensive observability stack.

This initiative follows a three-phase delivery model: Target Architecture definition, Analysis and Design, and Transformation / Execution. Each phase produces well-defined deliverables that feed into subsequent phases, ensuring traceability from requirements through to deployed infrastructure.

---

## Table of Contents

| Document | Title | Phase |
|----------|-------|-------|
| [00 - Overview](./00-overview.md) | Project Overview and Index (this document) | -- |
| [01 - Target Architecture](./01-target-architecture.md) | High-Level Architecture and Design Principles | Phase 1 |
| [02 - Analysis and Design](./02-analysis-and-design.md) | Requirements, Data Models, Auth Flows, Security | Phase 2 |
| [03 - Transformation and Execution](./03-transformation-execution.md) | Implementation Roadmap, Sprint Plan, Go-Live | Phase 3 |
| [04 - Keycloak Configuration](./04-keycloak-configuration.md) | Realm, Client, and Provider Configuration | Phase 2 |
| [05 - Infrastructure as Code](./05-infrastructure-as-code.md) | Terraform, Helm, and Kubernetes Manifests | Phase 3 |
| [06 - CI/CD Pipelines](./06-cicd-pipelines.md) | GitHub Actions / GitLab CI Pipeline Design | Phase 3 |
| [07 - Security by Design](./07-security-by-design.md) | OWASP, Pod Security, OPA, Secrets, TLS, Audit | Phase 2 |
| [08 - Authentication and Authorization](./08-authentication-authorization.md) | OIDC, SAML, JWT, MFA, RBAC, OPA | Phase 2 |
| [09 - User Lifecycle](./09-user-lifecycle.md) | Provisioning, Credentials, Sessions, GDPR | Phase 2/3 |
| [10 - Observability](./10-observability.md) | OpenTelemetry, Prometheus, Grafana, SLI/SLO | Phase 2/3 |
| [11 - Keycloak Customization](./11-keycloak-customization.md) | Themes, SPIs, Email Templates | Phase 2/3 |
| [12 - Environment Management](./12-environment-management.md) | Dev, QA, Prod Environments, Promotion | Phase 3 |
| [13 - Automation and Scripts](./13-automation-scripts.md) | Runbooks, kcadm, REST API, CronJobs | Phase 3 |
| [14 - Client Applications](./14-client-applications.md) | Integration Hub (10 framework-specific guides) | Phase 3 |
| [15 - Multi-Tenancy Design](./15-multi-tenancy-design.md) | Realm-per-Tenant Strategy, Isolation, Tenant Lifecycle | Phase 1 |
| [16 - Operations Runbook](./16-operations-runbook.md) | Incident Response, Day-2 Ops, Troubleshooting | Phase 3 |
| [17 - Disaster Recovery](./17-disaster-recovery.md) | Backup, Failover, RPO/RTO, Multi-Region DR | Phase 3 |
| [18 - Testing Strategy](./18-testing-strategy.md) | Unit, Integration, E2E, Performance, Security Testing | Phase 3 |
| [19 - Migration Strategy](./19-migration-strategy.md) | Community KC to RHBK, Data Migration, Cutover | Phase 3 |
| [20 - Compliance and Governance](./20-compliance-governance.md) | GDPR, Audit, Regulatory Compliance, Access Governance | Phase 2/3 |

### Client Application Guides (Document 14 Sub-Documents)

| Document | Framework | Language |
|----------|-----------|----------|
| [14-01 - Spring Boot](./14-01-spring-boot.md) | Spring Boot 3.4 | Java 17 |
| [14-02 - ASP.NET Core](./14-02-dotnet.md) | ASP.NET Core | C# / .NET 9 |
| [14-03 - NestJS](./14-03-nestjs.md) | NestJS 10 | TypeScript |
| [14-04 - Express](./14-04-express.md) | Express | Node.js 22 |
| [14-05 - FastAPI](./14-05-python-fastapi.md) | FastAPI | Python 3.12 |
| [14-06 - Next.js](./14-06-nextjs.md) | Next.js 15 | TypeScript |
| [14-07 - Angular](./14-07-angular.md) | Angular 19 | TypeScript |
| [14-08 - React](./14-08-react.md) | React 19 | TypeScript |
| [14-09 - Vue](./14-09-vue.md) | Vue 3.5 | TypeScript |
| [14-10 - Quarkus](./14-10-quarkus.md) | Quarkus 3.17 | Java 17 |

---

## Project Phases

### Phase 1: Target Architecture

Define the ideal end-state architecture, technology stack, and foundational design principles. This phase establishes the blueprint that all subsequent work follows.

**Key Deliverables:**
- High-level architecture diagrams
- Technology stack selection and version pinning
- Multi-tenancy strategy (Realm-per-Tenant)
- Network topology and namespace design
- High availability and disaster recovery strategy
- Design principles documentation

**References:** [01 - Target Architecture](./01-target-architecture.md)

### Phase 2: Analysis and Design

Conduct detailed analysis of functional and non-functional requirements. Produce data models, authentication and authorization flow designs, integration patterns, security threat models, and API specifications.

**Key Deliverables:**
- Functional and non-functional requirements
- Data model and ER diagrams
- Authentication flow sequence diagrams (OIDC, SAML, MFA)
- Authorization model (RBAC, OPA policies)
- Integration patterns (token exchange, introspection, backchannel logout)
- STRIDE threat model
- Performance requirements and SLA definitions

**References:** [02 - Analysis and Design](./02-analysis-and-design.md), [04 - Keycloak Configuration](./04-keycloak-configuration.md), [07 - Security by Design](./07-security-by-design.md), [08 - Authentication and Authorization](./08-authentication-authorization.md)

### Phase 3: Transformation / Execution

Implement, deploy, test, and go live. This phase translates the architecture and designs into running infrastructure, automated pipelines, and validated production workloads.

**Key Deliverables:**
- Terraform modules and Helm charts
- CI/CD pipelines (build, test, deploy)
- Keycloak cluster deployment on Kubernetes
- Observability stack deployment
- Performance and security test results
- Operations runbook and incident response procedures
- Go-live checklist and cutover plan

**References:** [03 - Transformation and Execution](./03-transformation-execution.md), [05 - Infrastructure as Code](./05-infrastructure-as-code.md), [06 - CI/CD Pipelines](./06-cicd-pipelines.md), [12 - Environment Management](./12-environment-management.md), [13 - Automation and Scripts](./13-automation-scripts.md)

---

## Technology Stack

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Identity Provider | Keycloak | 26.x (latest stable) | Multi-tenant authentication and authorization |
| Container Orchestration | Kubernetes | 1.31.x | Workload scheduling and service orchestration |
| Infrastructure as Code | Terraform | 1.10.x | Cloud resource provisioning and lifecycle management |
| Container Runtime | Docker | 27.x | Container image building and local development |
| Policy Engine | Open Policy Agent | 1.x | Fine-grained authorization policy enforcement |
| Telemetry Collector | OpenTelemetry Collector | 0.115.x | Metrics, traces, and logs collection and export |
| Metrics Store | Prometheus | 2.55.x | Time-series metrics storage and alerting |
| Dashboarding | Grafana | 11.x | Visualization, dashboards, and alerting UI |
| Package Manager | Helm | 3.16.x | Kubernetes application packaging and deployment |
| CI/CD | GitHub Actions / GitLab CI | -- | Automated build, test, and deployment pipelines |
| Keycloak SPI Language | Java | 17 | Keycloak extensions use Java's ServiceLoader mechanism (Keycloak platform requirement) |
| Database | PostgreSQL | 16.x | Keycloak persistent backend storage |

---

## Planning

Project planning artifacts, sprint boards, and milestone tracking are maintained in the project management system. Refer to the planning folder for:

- Sprint backlogs and velocity tracking
- Milestone definitions and acceptance criteria
- Risk register and mitigation plans
- RACI matrix and stakeholder map

---

## Document Conventions

The following conventions are used throughout this documentation set:

| Convention | Meaning |
|------------|---------|
| `code blocks` | CLI commands, configuration snippets, or file paths |
| **Bold text** | Key terms, emphasis on critical information |
| *Italic text* | Document titles, variable names, or first-use terminology |
| `mermaid` code blocks | Architecture, sequence, and ER diagrams rendered via Mermaid |
| Tables | Comparison matrices, configuration parameters, and structured data |
| Cross-references | Relative links (e.g., `[doc title](./XX-filename.md)`) connecting related documents |

**Naming conventions:**
- Documents are numbered `00` through `14` for ordering.
- Kubernetes namespaces follow the pattern `iam-<function>` (e.g., `iam-system`, `iam-observability`).
- Keycloak Realms follow the pattern `<tenant-slug>` (e.g., `acme-corp`, `globex-inc`).
- Terraform modules are named `module-<resource>` (e.g., `module-keycloak-cluster`).
- Helm releases are named `<app>-<environment>` (e.g., `keycloak-production`).

**Diagram tooling:** All diagrams are authored in Mermaid syntax and can be rendered in any Mermaid-compatible Markdown viewer (GitHub, GitLab, VS Code with extensions, etc.).

---

*This document is part of the Enterprise IAM Platform documentation set. For questions or contributions, follow the project's contribution guidelines and change management process.*
