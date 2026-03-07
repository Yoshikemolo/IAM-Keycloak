# Project Context - Enterprise IAM Keycloak

> **Purpose:** This document captures ALL known context about the project so that any team member or AI assistant can understand the full picture without needing to re-read source documents.
> **Last Updated:** 2026-03-07

---

## 1. Parties

### Client

- **Company:** X-IAM
- **Primary Contact:** Inaki Lardero
- **Role:** Project sponsor / technical lead on client side
- **Infrastructure Team:** Manages Terraform, Git, CI/CD, GKE clusters

### Provider

- **Company:** Ximplicity Software Solutions S.L.
- **Primary Contact:** Jorge Rodriguez
- **Role:** Keycloak expertise, architecture, L3 support
- **Positioning:** Deep IAM/Keycloak specialist; not a generalist infrastructure provider

---

## 2. Contract Structure

### Block A: Project (4 months)

Active project delivery covering architecture, design, and implementation.

| Sub-phase | Duration | Activities |
|-----------|----------|------------|
| Analysis | ~1.5 months | AS-IS documentation, gap analysis, risk assessment, requirements gathering |
| Design | Overlapping with analysis | Target architecture, AuthN/AuthZ models, 2FA design, integration design |
| Transformation / Execution | ~2.5 months | Migration to RHBK, 2FA rollout, code refactoring, IaC updates, testing, go-live |

### Block B: Operations (8 months)

Ongoing operational support after go-live.

| Aspect | Detail |
|--------|--------|
| Support Level | L3 only (Ximplicity); L1/L2 handled by client |
| Support Model | Hybrid (remote primary, on-site as needed) |
| SLA - Sev1 | Response: <=15 minutes, Resolution: <=5 hours |
| SLA - Sev2-4 | To be defined during Phase 3 |
| Reporting | Monthly reports (incidents, SLA compliance, trends) |

### Pricing

- **Base Rate:** 9,000 EUR/month
- **Note:** This covers Ximplicity's L3 support and Keycloak expertise services

---

## 3. Project Phases

### Phase 1: Target Architecture

Define the ideal end-state architecture for the IAM platform. Produces high-level architecture diagrams, technology stack decisions, multi-tenancy strategy, network topology, HA/DR strategy, and design principles.

### Phase 2: Analysis and Design

Conduct detailed analysis of the current system and produce design artifacts. Includes AS-IS documentation, gap analysis, risk assessment, technical debt evaluation, and designs for authentication models, 2FA, identity mappings, scopes/authorization, token templates, tenant onboarding, credential management, and Apigee integration.

### Phase 3: Transformation / Execution

Implement and deploy the target platform. Includes RHBK migration, 2FA rollout, code refactoring, IaC updates, telemetry implementation, runbook creation, support model definition, blue/green deployment, testing, and go-live.

---

## 4. Current System (AS-IS)

### Keycloak

- **Version:** Keycloak 26.4.2 (community edition)
- **Deployment:** GKE (Google Kubernetes Engine)
- **Regions:** Belgium and Madrid (multi-region)
- **Database:** Oracle DB (not PostgreSQL)
- **Users:** ~400 users
- **Tenants:** Multi-tenant with realm-per-tenant model
- **B2B Federation:** 2 federated organizations (SAML/OIDC)

### Microservices

- **JIT Microservice:** Handles just-in-time user provisioning during federated login (built on the selected runtime, e.g., Java 17 with Spring Boot or Quarkus)
- **Token Exchange Microservice:** Handles OAuth 2.0 token exchange flows (built on the selected runtime, e.g., Java 17 with Spring Boot or Quarkus)
- **Both** are deployed on Kubernetes alongside Keycloak

### Authentication Flow (Current)

```
Federated Login (B2B IdP)
    -> Keycloak (authentication, federation)
        -> JIT Microservice (user provisioning/sync)
            -> JWT issued
                -> Token Exchange Microservice
                    -> WAS (WebSphere Application Server - legacy)
                        -> Backend APIs
```

### Integration Points

- **Apigee:** API gateway sitting in front of backend APIs; validates/proxies tokens
- **BigQuery:** Receives audit/analytics data from the IAM platform
- **Oracle DB:** Keycloak persistent backend (not the standard PostgreSQL)
- **WAS (WebSphere):** Legacy application server; token exchange target; on decommissioning path (timeline TBD)

### Infrastructure

- **Container Orchestration:** GKE (Google Kubernetes Engine)
- **IaC:** Terraform (managed by client infrastructure team)
- **CI/CD:** GitHub Actions or GitLab CI (to be confirmed)
- **Container Images:** Docker
- **Regions:** europe-west1 (Belgium), europe-southwest1 (Madrid) -- exact zones TBC

### What the Client Infrastructure Team Manages

- Terraform modules and state
- Git repositories
- CI/CD pipelines
- GKE cluster provisioning and management
- Network infrastructure
- DNS and certificates

### What Ximplicity Manages

- Keycloak configuration and expertise
- Custom SPI development
- Architecture decisions for IAM components
- L3 support during Block B
- Migration planning and execution guidance

---

## 5. Target System (TO-BE)

### Migration Target

- **From:** Community Keycloak 26.4.2
- **To:** Red Hat Build of Keycloak (based on Keycloak 26.x, enterprise-supported)

### New Capabilities

- **2FA/MFA:** Add multi-factor authentication (TOTP, WebAuthn, or other methods TBD)
- **OpenTelemetry Improvements:** Enhanced observability with traces, metrics, and structured logs
- **Security Hardening:** Network policies, OPA authorization, container hardening, secret management improvements

### Client Applications (Planned Integrations)

The following application types will integrate with the IAM platform:

| Technology | Protocol | Notes |
|-----------|----------|-------|
| Java / Spring Boot | OIDC | Backend resource server |
| Java / Quarkus | OIDC | Backend resource server (native compilation support) |
| C# / ASP.NET Core | OIDC | Backend resource server |
| TypeScript / NestJS | OIDC | Backend resource server |
| JavaScript / Express | OIDC | Backend resource server |
| Python / FastAPI | OIDC | Backend resource server (OpenAPI integration) |
| TypeScript / Next.js | OIDC (SSR + PKCE) | Frontend / full-stack application |
| TypeScript / Angular | OIDC (PKCE) | Frontend SPA |
| TypeScript / React | OIDC (PKCE) | Frontend SPA |
| TypeScript / Vue | OIDC (PKCE) | Frontend SPA |

> **Note:** The repository includes working integration examples for all the technologies listed above. See [doc/14 - Client Applications Hub](../doc/14-client-applications.md) for detailed per-framework guides. When adapting this project for a specific deployment, select the framework(s) that match your team's technology stack.

### Technology Stack (Full)

| Component | Technology | Notes |
|-----------|-----------|-------|
| Identity Provider | Red Hat Build of Keycloak (26.x) | Migration from community KC |
| Container Orchestration | GKE (Kubernetes) | Client-managed, multi-region |
| Database | Oracle DB | Client-managed; non-standard for KC |
| API Gateway | Apigee | Client-managed |
| IaC | Terraform | Client-managed |
| CI/CD | GitHub Actions / GitLab CI | Client-managed |
| Containers | Docker | -- |
| Policy Engine | OPA (Open Policy Agent) | Fine-grained AuthZ |
| Protocols | SAML, OIDC, JWT, OAuth 2.0 | -- |
| Telemetry | OpenTelemetry | Collector + OTLP export |
| Metrics | Prometheus | Scraping + alerting |
| Dashboards | Grafana | Visualization |
| Analytics | BigQuery | Audit and analytics data |
| Language (microservices) | Selected runtime (e.g., Java 17) | JIT + token exchange; framework may vary (Spring Boot, Quarkus, etc.) |

---

## 6. Key Risks Identified from RFP Analysis

| Risk | Detail |
|------|--------|
| Oracle DB with Keycloak | Oracle is a supported but non-standard backend for Keycloak; fewer community resources; JDBC driver licensing considerations |
| Community to RHBK migration | While versions are aligned, custom SPIs and configurations may behave differently; thorough testing required |
| Multi-region complexity | Cross-region Infinispan clustering adds latency and complexity; session consistency challenges |
| WAS legacy dependency | Token exchange to WAS creates a dependency on legacy infrastructure; decommissioning timeline unclear |
| 4-month Block A timeline | Ambitious scope (architecture + analysis + design + implementation + testing + go-live) in 4 months |
| L3-only support model | Requires clear L1/L2 capability on client side; poorly defined boundaries could cause friction |
| 2FA rollout to existing users | Change management challenge; users need enrollment support; potential productivity impact |
| Apigee integration complexity | Token validation, policy coordination, error handling between Apigee and Keycloak require careful design |

---

## 7. Strategic Decisions

| Decision | Rationale |
|----------|-----------|
| L3 support only | Ximplicity positions as deep expert, not helpdesk; client has capable infra team for L1/L2 |
| Hybrid support model | Remote-first for cost efficiency; on-site available for critical situations or workshops |
| 9,000 EUR/month pricing | Competitive rate for L3 Keycloak expertise |
| Three-phase delivery | Standard enterprise delivery model; ensures traceability from requirements to deployment |
| Realm-per-tenant isolation | Keycloak best practice for multi-tenant deployments; strong isolation without separate instances |
| Red Hat Build of Keycloak | Client requirement for enterprise support, certified builds, and predictable release cycle |

---

## 8. RFP and Proposal Documents

### Source Documents

| Document | Location | Language |
|----------|----------|----------|
| RFP from X-IAM | `doc/RFP_subco.pdf` | Spanish |
| Questions and Answers | `doc/X-IAM-Cuestiones-sobre-la-RFP_ES20260303001-RESPUESTAS.pdf` | Spanish |
| Ximplicity Proposal | `doc/propuesta_servicios_keycloak_ximplicity_ES20260304001.pdf` | Spanish |

### Questions Sent and Answers Received (Summary)

The file `doc/X-IAM-Cuestiones-sobre-la-RFP_ES20260303001-RESPUESTAS.pdf` contains questions sent by Ximplicity to X-IAM regarding the RFP, along with X-IAM responses. Key topics covered:

- Clarification on scope boundaries (L3 only vs full support)
- Confirmation of existing infrastructure (GKE, Oracle DB, Apigee)
- Details on current Keycloak deployment and version
- Clarification on B2B federation setup
- Details on microservices (JIT, token exchange)
- Confirmation of multi-region setup
- Timeline and milestone expectations
- SLA definitions and severity levels

**Note:** These documents are in Spanish. Refer to the original PDFs for exact wording.

---

## 9. Technical Details from Conversations

### Keycloak Specifics

- Current version is 26.4.2 (community)
- Using Oracle DB instead of PostgreSQL
- Multi-tenant with realm-per-tenant
- 2 B2B organizations federated (likely SAML)
- ~400 users across all realms
- JIT provisioning via custom microservice (e.g., Java 17 with Spring Boot or Quarkus)
- Token exchange handled by separate microservice (e.g., Java 17 with Spring Boot or Quarkus)
- BigQuery used for audit/analytics data

### Infrastructure Specifics

- GKE multi-region: Belgium (europe-west1) and Madrid (europe-southwest1)
- Terraform managed by client infrastructure team
- CI/CD managed by client (GitHub Actions or GitLab CI -- to confirm)
- Client handles all infrastructure provisioning; Ximplicity advises on IAM-specific config

### Migration Specifics

- Target: Red Hat Build of Keycloak (enterprise-supported version of KC 26.x)
- Must maintain all existing functionality during migration
- Zero-downtime migration preferred (blue/green deployment)
- Database remains Oracle DB (no DB migration planned)

### New Feature Specifics

- 2FA/MFA to be added for all users
- OpenTelemetry to be improved (not greenfield -- some telemetry exists)
- Security hardening (network policies, OPA, container security, secret management)
- Support for multiple client application technologies (see [doc/14](../doc/14-client-applications.md) for the full list: Spring Boot, Quarkus, ASP.NET Core, NestJS, Express, FastAPI, Next.js, Angular, React, Vue)

---

## 10. Document Set Structure

The project documentation follows a numbered structure (00-20) in the `doc/` folder:

| # | Title | Phase | Purpose |
|---|-------|-------|---------|
| [00](../doc/00-overview.md) | Overview | -- | Project index, technology stack, conventions |
| [01](../doc/01-target-architecture.md) | Target Architecture | Phase 1 | High-level architecture, design principles, HA/DR |
| [02](../doc/02-analysis-and-design.md) | Analysis and Design | Phase 2 | Requirements, data models, auth flows, security |
| [03](../doc/03-transformation-execution.md) | Transformation and Execution | Phase 3 | Implementation roadmap, sprint plan, go-live |
| [04](../doc/04-keycloak-configuration.md) | Keycloak Configuration | Phase 2 | Realm, client, provider configuration |
| [05](../doc/05-infrastructure-as-code.md) | Infrastructure as Code | Phase 3 | Terraform, Helm, Kubernetes manifests |
| [06](../doc/06-cicd-pipelines.md) | CI/CD Pipelines | Phase 3 | Build, test, deploy automation |
| [07](../doc/07-security-by-design.md) | Security by Design | Phase 2 | OWASP, Pod Security, OPA, Secrets, TLS, Audit |
| [08](../doc/08-authentication-authorization.md) | Authentication and Authorization | Phase 2 | OIDC, SAML, JWT, MFA, RBAC, OPA |
| [09](../doc/09-user-lifecycle.md) | User Lifecycle | Phase 2/3 | Provisioning, credentials, sessions, GDPR |
| [10](../doc/10-observability.md) | Observability | Phase 2/3 | OpenTelemetry, Prometheus, Grafana, SLI/SLO |
| [11](../doc/11-keycloak-customization.md) | Keycloak Customization | Phase 2/3 | Themes, SPIs, email templates |
| [12](../doc/12-environment-management.md) | Environment Management | Phase 3 | Dev, QA, Prod environments, promotion |
| [13](../doc/13-automation-scripts.md) | Automation and Scripts | Phase 3 | Runbooks, kcadm, REST API, CronJobs |
| [14](../doc/14-client-applications.md) | Client Applications | Phase 3 | Integration hub (10 framework-specific guides) |
| [15](../doc/15-multi-tenancy-design.md) | Multi-Tenancy Design | Phase 1 | Realm-per-tenant strategy, isolation, tenant lifecycle |
| [16](../doc/16-operations-runbook.md) | Operations Runbook | Phase 3 | Incident response, day-2 ops, troubleshooting |
| [17](../doc/17-disaster-recovery.md) | Disaster Recovery | Phase 3 | Backup, failover, RPO/RTO, multi-region DR |
| [18](../doc/18-testing-strategy.md) | Testing Strategy | Phase 3 | Unit, integration, E2E, performance, security testing |
| [19](../doc/19-migration-strategy.md) | Migration Strategy | Phase 3 | Community KC to RHBK, data migration, cutover |
| [20](../doc/20-compliance-governance.md) | Compliance and Governance | Phase 2/3 | GDPR, audit, regulatory compliance |

---

## 11. Important Notes for AI Assistants

When resuming work on this project:

1. **Always check [planning/progress-tracker.md](./progress-tracker.md) first** for the latest status, open questions, and session log.
2. **The existing doc/01 and doc/05 are generic templates** that use PostgreSQL and AWS/Azure examples. They must be adapted to the client's actual stack (GKE, Oracle DB, Apigee).
3. **The client's primary language is Spanish.** All RFP documents and communications are in Spanish. Project documentation is in English.
4. **Ximplicity is the provider, not the client.** Do not confuse roles. X-IAM is the client; Ximplicity provides Keycloak expertise.
5. **Oracle DB is non-standard for Keycloak.** Most Keycloak documentation and community resources assume PostgreSQL. Always verify Oracle DB compatibility when referencing Keycloak features.
6. **The client infrastructure team is separate.** They manage Terraform, GKE, CI/CD. Ximplicity advises but does not directly manage infrastructure.
7. **Block A is time-boxed to 4 months.** This is tight for the full scope. Prioritization and scope management are critical.
8. **Block B is L3 support only.** Do not design for L1/L2 support responsibilities.

---

*This document should be updated whenever significant new context is acquired (client meetings, decisions, technical discoveries).*
