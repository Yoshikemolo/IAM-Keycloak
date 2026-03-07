# Phase 2: Analysis and Design - Task Breakdown

> **Phase Duration:** Part of Block A (~1.5 months, overlapping with Phase 1 completion)
> **Objective:** Conduct detailed analysis of current state, identify gaps, and produce comprehensive design artifacts
> **Status:** Not Started

---

## 1. Analysis Activities

### 1.1 AS-IS Documentation

- [ ] Document current Keycloak 26.4.2 deployment configuration
- [ ] Export and analyze existing realm configurations
- [ ] Document current authentication flows (federated login -> KC -> JIT -> JWT -> token exchange -> WAS -> APIs)
- [ ] Map all current SAML and OIDC identity provider configurations (2 B2B orgs)
- [ ] Document current client registrations and scopes
- [ ] Document JIT microservice functionality and integration points (built on the selected runtime, e.g., Java 17)
- [ ] Document token exchange microservice functionality
- [ ] Document current BigQuery integration (what data, what format, what frequency)
- [ ] Document current Oracle DB schema and usage patterns
- [ ] Document current Apigee configuration and API policies
- [ ] Document current GKE deployment topology (Belgium + Madrid)
- [ ] Document current Terraform configurations and modules
- [ ] Document current CI/CD pipelines (GitHub Actions or GitLab CI)
- [ ] Document current monitoring and alerting setup
- [ ] Document current WAS legacy integration and dependencies
- [ ] Inventory all ~400 users: distribution across realms, roles, federation sources
- [ ] Document current credential management processes
- [ ] Document current onboarding/offboarding workflows

### 1.2 Gap Analysis

- [ ] Compare community Keycloak 26.4.2 features vs Red Hat Build of Keycloak features
- [ ] Identify configuration differences between community and RHBK
- [ ] Identify custom SPIs or extensions that need migration
- [ ] Identify deprecated features or APIs in use
- [ ] Compare current authentication flows against security best practices
- [ ] Identify missing MFA/2FA capabilities
- [ ] Identify observability gaps (missing metrics, traces, logs)
- [ ] Identify IaC gaps (manual configurations not captured in Terraform)
- [ ] Identify missing network security controls
- [ ] Identify missing operational procedures and runbooks
- [ ] Document gap between current and target architecture (from Phase 1)

### 1.3 Risk Assessment

- [ ] Assess migration risk: community Keycloak to RHBK
- [ ] Assess risk of Oracle DB compatibility issues with RHBK
- [ ] Assess multi-region failover risks
- [ ] Assess impact of 2FA rollout on existing ~400 users
- [ ] Assess B2B federation continuity risks during migration
- [ ] Assess WAS legacy dependency risks
- [ ] Assess data loss risks during migration
- [ ] Assess downtime risk and business impact
- [ ] Assess vendor lock-in risks
- [ ] Document risk mitigation strategies for each identified risk

### 1.4 Technical Debt Evaluation

- [ ] Evaluate JIT microservice code quality and maintainability
- [ ] Evaluate token exchange microservice code quality
- [ ] Assess Terraform module quality and reusability
- [ ] Identify hardcoded configurations that should be parameterized
- [ ] Assess container image hygiene (base image currency, vulnerability scan results)
- [ ] Evaluate secret management practices
- [ ] Assess logging and error handling consistency
- [ ] Document technical debt remediation priorities

---

## 2. Design Activities

### 2.1 Target Operating Model (TOM)

- [ ] Define roles and responsibilities for IAM platform operations
- [ ] Define L1/L2/L3 support boundaries (client L1/L2, Ximplicity L3)
- [ ] Define escalation procedures and SLA targets
- [ ] Define change management process for IAM configuration changes
- [ ] Define incident management process
- [ ] Define capacity management process
- [ ] Define release management process
- [ ] Document on-call rotation model (if applicable)

### 2.2 Authentication Models (AuthN)

- [ ] Design OIDC authentication flow for web applications
- [ ] Design OIDC authentication flow for SPAs (PKCE)
- [ ] Design OIDC authentication flow for mobile applications
- [ ] Design SAML authentication flow for B2B federation
- [ ] Design service-to-service authentication (client credentials)
- [ ] Design device authorization flow (if needed)
- [ ] Document token lifetimes and refresh strategies per client type
- [ ] Design session management strategy (SSO, SLO, idle/max timeouts)
- [ ] Design authentication flow for each supported client application type (see [doc/14 - Client Applications Hub](../doc/14-client-applications.md) for the full list of supported frameworks):
  - [ ] Java backend applications (e.g., Spring Boot, Quarkus)
  - [ ] .NET backend applications (e.g., ASP.NET Core)
  - [ ] Node.js backend applications (e.g., NestJS, Express)
  - [ ] Python backend applications (e.g., FastAPI)
  - [ ] Frontend SPA and SSR applications (e.g., Next.js, Angular, React, Vue)

### 2.3 2FA / MFA Design

- [ ] Evaluate 2FA methods: TOTP, WebAuthn/FIDO2, SMS, email OTP
- [ ] Design 2FA enrollment flow (first-time setup)
- [ ] Design 2FA authentication flow (step-up authentication)
- [ ] Design 2FA recovery flow (lost device, backup codes)
- [ ] Define 2FA policy per realm / per client / per role
- [ ] Design conditional MFA (risk-based, adaptive)
- [ ] Plan 2FA migration strategy for existing ~400 users
- [ ] Define grace period and enforcement timeline
- [ ] Design admin bypass / break-glass procedures for 2FA

### 2.4 Identity Mappings

- [ ] Design user attribute mapping from federated IdPs to Keycloak
- [ ] Design JIT provisioning rules (what attributes, what defaults)
- [ ] Design group and role mapping from external sources
- [ ] Design user profile schema (required, optional, read-only attributes)
- [ ] Design B2B organization-to-realm mapping
- [ ] Document identity lifecycle (creation, update, disable, delete)
- [ ] Design account linking strategy (multiple IdPs, same user)

### 2.5 Scopes and Authorization (AuthZ)

- [ ] Define OAuth 2.0 scopes per application type
- [ ] Design RBAC model (roles, groups, permissions)
- [ ] Design realm-level vs client-level role hierarchy
- [ ] Evaluate OPA integration for fine-grained authorization
- [ ] Define scope-to-permission mapping
- [ ] Design consent management (if user-facing OAuth flows needed)
- [ ] Design API authorization strategy (Apigee + Keycloak token validation)
- [ ] Document authorization decision flow (who checks what, where)

### 2.6 Token Templates

- [ ] Design access token claims (standard + custom)
- [ ] Design ID token claims
- [ ] Design refresh token policy
- [ ] Define token mapper configurations per client
- [ ] Design token exchange flow (existing microservice adaptation)
- [ ] Define token size constraints and optimization
- [ ] Document token validation requirements per consumer application
- [ ] Design client scope templates for each application type

### 2.7 Tenant Onboarding Design

- [ ] Design automated realm provisioning workflow
- [ ] Define realm template with baseline configuration
- [ ] Design IdP federation setup process for new B2B partners
- [ ] Design user migration process for new tenants
- [ ] Define tenant-specific branding and theme configuration
- [ ] Design self-service vs admin-provisioned tenant models
- [ ] Document onboarding checklist and acceptance criteria

### 2.8 Credential Management

- [ ] Design password policy (complexity, rotation, history)
- [ ] Design credential reset flows (self-service, admin-initiated)
- [ ] Design API key / service account credential management
- [ ] Design certificate management for SAML signing and encryption
- [ ] Design secret rotation strategy for client secrets
- [ ] Document credential storage and encryption at rest

### 2.9 Apigee Integration Design

- [ ] Design token validation flow at Apigee layer
- [ ] Design Apigee-to-Keycloak communication patterns
- [ ] Define API policies for authentication enforcement
- [ ] Design rate limiting coordination between Apigee and Keycloak
- [ ] Document API consumer onboarding via Apigee developer portal
- [ ] Design error handling and response standardization
- [ ] Define Apigee policy templates for Keycloak-protected APIs

---

## 3. Dependencies

| Task | Depends On | Notes |
|------|-----------|-------|
| AS-IS documentation | Access to current Keycloak admin console and realm exports | Need client to provide access or exports |
| AS-IS documentation | Access to JIT and token exchange microservice source code | Need repository access |
| AS-IS documentation | Access to current Terraform configurations | Need repository access |
| AS-IS documentation | Access to current Apigee configuration | Need client Apigee team involvement |
| Gap analysis | Completed AS-IS documentation | Sequential dependency |
| Gap analysis | Phase 1 target architecture finalized | Need target state to compare against |
| AuthN model design | AS-IS authentication flows documented | Need to understand current state first |
| 2FA design | Client confirmation of preferred 2FA methods | Business decision needed |
| Apigee integration design | Current Apigee policies and API inventory | Need client API team involvement |
| Token templates | Client application inventory with claim requirements | Need app teams to specify needs |
| TOM design | Client organizational structure and team capabilities | Need client ops team involvement |

---

## 4. Deliverable Documents

| Deliverable | Target Document | Status |
|-------------|----------------|--------|
| AS-IS analysis results | [doc/02-analysis-and-design.md](../doc/02-analysis-and-design.md) | Not Started |
| Multi-tenancy and realm design | [doc/15-multi-tenancy-design.md](../doc/15-multi-tenancy-design.md) | Not Started |
| Keycloak configuration design | [doc/04-keycloak-configuration.md](../doc/04-keycloak-configuration.md) | Not Started |
| Observability design | [doc/10-observability.md](../doc/10-observability.md) | Not Started |
| Security hardening design | [doc/07-security-by-design.md](../doc/07-security-by-design.md) | Not Started |
| OPA authorization design | [doc/08-authentication-authorization.md](../doc/08-authentication-authorization.md) | Not Started |
| Custom SPI requirements | [doc/11-keycloak-customization.md](../doc/11-keycloak-customization.md) | Not Started |
| Compliance requirements | [doc/20-compliance-governance.md](../doc/20-compliance-governance.md) | Not Started |

---

## 5. Status Tracking

| Activity | Status | Assignee | Notes |
|----------|--------|----------|-------|
| AS-IS: Keycloak configuration | Not Started | -- | Awaiting access |
| AS-IS: Authentication flows | Not Started | -- | Awaiting access |
| AS-IS: Microservices | Not Started | -- | Awaiting code access |
| AS-IS: Infrastructure | Not Started | -- | Awaiting Terraform access |
| AS-IS: Apigee | Not Started | -- | Awaiting client API team |
| Gap analysis | Not Started | -- | Blocked on AS-IS |
| Risk assessment | Not Started | -- | Partially pre-populated from RFP analysis |
| Technical debt evaluation | Not Started | -- | Blocked on code access |
| TOM design | Not Started | -- | -- |
| AuthN models | Not Started | -- | -- |
| 2FA/MFA design | Not Started | -- | -- |
| Identity mappings | Not Started | -- | -- |
| Scopes/AuthZ design | Not Started | -- | -- |
| Token templates | Not Started | -- | -- |
| Onboarding design | Not Started | -- | -- |
| Credential management | Not Started | -- | -- |
| Apigee integration design | Not Started | -- | -- |

### Completion Estimate

- **Overall Phase 2 Progress:** 0%
- **Blocking items:** Client access to existing systems and configurations

---

*Last updated: 2026-03-07*
