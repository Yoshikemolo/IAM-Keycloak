# Phase 3: Transformation / Execution - Task Breakdown

> **Phase Duration:** ~2.5 months within Block A
> **Objective:** Implement, migrate, deploy, test, and go live with the target IAM platform
> **Status:** Not Started
> **Prerequisites:** Phase 1 and Phase 2 deliverables must be substantially complete

---

## 1. Migration to Red Hat Build of Keycloak

### 1.1 Pre-Migration Preparation

- [ ] Obtain Red Hat Build of Keycloak subscription and container images
- [ ] Set up RHBK in a non-production environment (dev/staging)
- [ ] Validate Oracle DB JDBC driver compatibility with RHBK
- [ ] Test RHBK startup and basic functionality with Oracle DB backend
- [ ] Validate custom SPIs compile and load against RHBK
- [ ] Validate custom themes render correctly on RHBK
- [ ] Document all configuration differences between community KC 26.4.2 and RHBK
- [ ] Create migration runbook with step-by-step procedures

### 1.2 Realm Migration

- [ ] Export all realm configurations from community Keycloak
- [ ] Validate realm exports are compatible with RHBK import
- [ ] Test realm import in staging environment
- [ ] Validate all authentication flows work post-import
- [ ] Validate all identity provider federations (2 B2B orgs) work post-import
- [ ] Validate all client registrations and scopes are intact
- [ ] Validate user data integrity (all ~400 users)
- [ ] Validate role and group assignments
- [ ] Test federated login end-to-end for both B2B organizations

### 1.3 Database Migration

- [ ] Analyze community Keycloak schema vs RHBK schema differences (if any)
- [ ] Create database migration scripts (if schema changes needed)
- [ ] Test database migration in staging with production data copy
- [ ] Validate data integrity post-migration
- [ ] Document rollback procedure for database changes

---

## 2. 2FA / MFA Migration

- [ ] Deploy chosen 2FA provider (TOTP, WebAuthn, etc.) in staging
- [ ] Configure 2FA authentication flow in Keycloak
- [ ] Configure conditional MFA policies per Phase 2 design
- [ ] Test 2FA enrollment flow end-to-end
- [ ] Test 2FA authentication flow end-to-end
- [ ] Test 2FA recovery flow (backup codes, admin reset)
- [ ] Test break-glass procedure for 2FA bypass
- [ ] Create user communication plan for 2FA rollout
- [ ] Create user enrollment guide documentation
- [ ] Deploy 2FA in production with grace period
- [ ] Monitor enrollment progress and address user issues
- [ ] Enforce 2FA after grace period expires

---

## 3. Code Refactoring

### 3.1 JIT Microservice

- [ ] Review and refactor JIT microservice per Phase 2 design recommendations
- [ ] Update dependencies to current stable versions
- [ ] Ensure compatibility with the selected runtime and framework (e.g., Java 17 / Spring Boot or Quarkus) and apply current best practices
- [ ] Add/improve unit tests
- [ ] Add/improve integration tests
- [ ] Update Dockerfile for RHBK compatibility
- [ ] Address technical debt items identified in Phase 2

### 3.2 Token Exchange Microservice

- [ ] Review and refactor token exchange microservice per Phase 2 design
- [ ] Update dependencies to current stable versions
- [ ] Ensure compatibility with the selected runtime and framework (e.g., Java 17 / Spring Boot or Quarkus) and apply current best practices
- [ ] Add/improve unit tests
- [ ] Add/improve integration tests
- [ ] Update Dockerfile
- [ ] Address technical debt items identified in Phase 2

### 3.3 Custom SPIs (if applicable)

- [ ] Refactor custom SPIs for RHBK compatibility
- [ ] Update SPI build pipeline
- [ ] Test SPIs in isolation
- [ ] Test SPIs integrated with RHBK

---

## 4. Infrastructure as Code Updates

### 4.1 Terraform Updates

- [ ] Update Terraform modules for RHBK (image references, configuration)
- [ ] Update GKE cluster modules if version changes needed
- [ ] Update networking modules for any topology changes
- [ ] Add/update Oracle DB connection configuration
- [ ] Add/update Apigee integration resources (if managed via Terraform)
- [ ] Update secret management configuration
- [ ] Run `terraform plan` against all environments and review changes
- [ ] Apply Terraform changes to dev environment
- [ ] Apply Terraform changes to staging environment
- [ ] Apply Terraform changes to production environment (with approval)

### 4.2 Helm Chart Updates

- [ ] Update Keycloak Helm chart for RHBK (image, env vars, configuration)
- [ ] Update values files for all environments (dev, staging, prod)
- [ ] Update observability stack Helm charts if needed
- [ ] Test Helm deployments in dev environment
- [ ] Test Helm deployments in staging environment

### 4.3 Kubernetes Manifests

- [ ] Update NetworkPolicies per Phase 2 security design
- [ ] Update ResourceQuotas and LimitRanges
- [ ] Update PodDisruptionBudgets
- [ ] Update HorizontalPodAutoscaler configurations
- [ ] Add/update ServiceMonitor resources for Prometheus
- [ ] Update namespace configurations and labels

---

## 5. Telemetry Implementation

### 5.1 OpenTelemetry

- [ ] Deploy OpenTelemetry Collector in GKE clusters (Belgium + Madrid)
- [ ] Configure RHBK to export traces via OTLP
- [ ] Configure RHBK to export metrics via OTLP
- [ ] Configure structured JSON logging for RHBK
- [ ] Configure JIT microservice telemetry
- [ ] Configure token exchange microservice telemetry
- [ ] Validate trace propagation across the full authentication flow
- [ ] Configure trace sampling strategy (head-based vs tail-based)

### 5.2 Prometheus and Grafana

- [ ] Deploy/update Prometheus in both regions
- [ ] Configure ServiceMonitors for RHBK metrics scraping
- [ ] Create Keycloak operational dashboard in Grafana
- [ ] Create authentication flow performance dashboard
- [ ] Create error rate and SLA compliance dashboard
- [ ] Create multi-region comparison dashboard
- [ ] Configure alerting rules for critical metrics:
  - [ ] Authentication failure rate threshold
  - [ ] Token issuance latency threshold
  - [ ] Pod restart / CrashLoopBackOff alerts
  - [ ] Database connection pool exhaustion
  - [ ] Certificate expiration warnings
  - [ ] Disk usage thresholds
- [ ] Configure alert notification channels (email, Slack, PagerDuty)
- [ ] Test alert firing and notification delivery

### 5.3 Logging

- [ ] Configure centralized log aggregation (Loki, Stackdriver, or equivalent)
- [ ] Define log retention policies
- [ ] Create log-based alerts for security events (brute force, account lockout)
- [ ] Ensure audit log completeness for compliance requirements

---

## 6. Procedures and Runbooks

- [ ] Write operational runbook: routine Keycloak administration tasks
- [ ] Write operational runbook: realm provisioning and configuration
- [ ] Write operational runbook: user management (create, disable, delete, unlock)
- [ ] Write incident response runbook: Keycloak service degradation
- [ ] Write incident response runbook: database connectivity issues
- [ ] Write incident response runbook: federation failures
- [ ] Write incident response runbook: certificate expiration
- [ ] Write incident response runbook: security incident (compromised credentials)
- [ ] Write disaster recovery runbook: full cluster rebuild
- [ ] Write disaster recovery runbook: database restore
- [ ] Write disaster recovery runbook: region failover
- [ ] Write maintenance runbook: RHBK version upgrade procedure
- [ ] Write maintenance runbook: certificate rotation
- [ ] Write maintenance runbook: secret rotation
- [ ] Write maintenance runbook: database maintenance (Oracle DB)
- [ ] Review all runbooks with client infrastructure team

---

## 7. Support Model Definition

- [ ] Finalize L1/L2/L3 support boundaries document
- [ ] Define escalation matrix with contact details
- [ ] Define SLA targets per severity level:
  - [ ] Sev1: response <=15 min, resolution <=5 hours
  - [ ] Sev2: define targets
  - [ ] Sev3: define targets
  - [ ] Sev4: define targets
- [ ] Define severity classification criteria
- [ ] Set up ticketing system integration (Jira or equivalent)
- [ ] Define communication channels and protocols
- [ ] Define on-call schedule for Block B operations period
- [ ] Create support knowledge base with common issues and resolutions
- [ ] Define monthly reporting template (incidents, SLA compliance, trends)
- [ ] Conduct support handoff session with client team

---

## 8. Blue/Green Deployment Strategy

- [ ] Design blue/green deployment architecture for Keycloak
- [ ] Configure two parallel deployment slots (blue and green) in GKE
- [ ] Implement traffic switching mechanism (ingress weight, DNS, or service mesh)
- [ ] Document deployment procedure:
  - [ ] Deploy new version to inactive slot
  - [ ] Run smoke tests against inactive slot
  - [ ] Switch traffic to new slot
  - [ ] Monitor for errors
  - [ ] Rollback procedure if issues detected
- [ ] Test blue/green deployment in staging
- [ ] Document rollback time targets (< 5 minutes)
- [ ] Integrate blue/green deployment into CI/CD pipeline

---

## 9. Testing and Validation

### 9.1 Functional Testing

- [ ] Test all authentication flows (OIDC, SAML, MFA)
- [ ] Test all token exchange flows
- [ ] Test JIT provisioning for both B2B organizations
- [ ] Test user lifecycle operations (create, update, disable, delete)
- [ ] Test role and permission assignments
- [ ] Test session management (SSO, SLO, timeout)
- [ ] Test Apigee integration with RHBK tokens
- [ ] Test client application integration for each supported technology (see [doc/14 - Client Applications Hub](../doc/14-client-applications.md) for the full list):
  - [ ] Java backends (e.g., Spring Boot, Quarkus)
  - [ ] .NET backends (e.g., ASP.NET Core)
  - [ ] Node.js backends (e.g., NestJS, Express)
  - [ ] Python backends (e.g., FastAPI)
  - [ ] Frontend applications (e.g., Next.js, Angular, React, Vue)

### 9.2 Performance Testing

- [ ] Define performance test scenarios and acceptance criteria
- [ ] Set up performance test environment
- [ ] Execute authentication throughput tests
- [ ] Execute token issuance throughput tests
- [ ] Execute concurrent session tests
- [ ] Execute federated login latency tests
- [ ] Analyze results and compare against SLA targets
- [ ] Document performance baselines for ongoing monitoring

### 9.3 Security Testing

- [ ] Execute vulnerability scan on RHBK container image
- [ ] Execute OWASP ZAP scan against Keycloak endpoints
- [ ] Test brute force protection configuration
- [ ] Test account lockout policies
- [ ] Test CORS configuration
- [ ] Test CSP headers
- [ ] Test TLS configuration (SSL Labs A+ target)
- [ ] Test token security (signature validation, expiration enforcement)
- [ ] Validate network policy enforcement (pen test network segmentation)
- [ ] Review Keycloak admin console access restrictions

### 9.4 Disaster Recovery Testing

- [ ] Test region failover (Belgium -> Madrid and reverse)
- [ ] Test database restore from backup
- [ ] Test full cluster rebuild from IaC
- [ ] Measure actual RTO and compare against targets
- [ ] Document test results and gaps

---

## 10. Go-Live Checklist

### Pre-Go-Live

- [ ] All Phase 1 and Phase 2 deliverables approved by client
- [ ] All functional tests passing
- [ ] Performance test results meet SLA targets
- [ ] Security test results show no critical or high vulnerabilities
- [ ] DR test completed successfully
- [ ] All runbooks reviewed and approved
- [ ] Support model agreed and signed off
- [ ] Rollback procedure tested and documented
- [ ] Communication plan prepared for stakeholders and end users
- [ ] 2FA enrollment guide distributed to users
- [ ] Change advisory board (CAB) approval obtained (if required)
- [ ] Maintenance window scheduled and communicated

### Go-Live Execution

- [ ] Create final backup of current community Keycloak
- [ ] Execute blue/green deployment to production
- [ ] Run production smoke tests
- [ ] Validate authentication flows with real users (pilot group)
- [ ] Monitor error rates and latency for first 30 minutes
- [ ] Confirm all B2B federation flows working
- [ ] Confirm Apigee integration working
- [ ] Confirm BigQuery integration working
- [ ] Decision point: proceed or rollback

### Post-Go-Live

- [ ] Monitor production for 24 hours (hypercare period)
- [ ] Monitor for 72 hours with reduced alert thresholds
- [ ] Collect and address any user-reported issues
- [ ] Conduct post-go-live review meeting
- [ ] Document lessons learned
- [ ] Transition to Block B operations support model
- [ ] Close out Block A project deliverables

---

## 11. Dependencies

| Task | Depends On | Notes |
|------|-----------|-------|
| RHBK deployment | Red Hat subscription active, images available | Commercial dependency |
| Realm migration | Phase 2 AS-IS documentation complete | Need full understanding of current state |
| Code refactoring | Phase 2 technical debt evaluation | Need priorities defined |
| IaC updates | Phase 1 target architecture finalized | Need target state defined |
| Telemetry | Phase 2 observability design | Need design before implementation |
| Runbooks | Phase 2 TOM and all design artifacts | Need operational model defined |
| Testing | All implementation tasks complete | Sequential dependency |
| Go-live | All testing passed, client approval | Gate dependency |

---

## 12. Status Tracking

| Work Stream | Status | Assignee | Notes |
|-------------|--------|----------|-------|
| RHBK migration prep | Not Started | -- | Blocked on Phase 1/2 |
| Realm migration | Not Started | -- | Blocked on access to current KC |
| Database migration | Not Started | -- | Blocked on Oracle DB analysis |
| 2FA implementation | Not Started | -- | Blocked on Phase 2 2FA design |
| JIT microservice refactor | Not Started | -- | Blocked on code access |
| Token exchange refactor | Not Started | -- | Blocked on code access |
| Terraform updates | Not Started | -- | Blocked on Phase 1 |
| Helm updates | Not Started | -- | Blocked on Phase 1 |
| OpenTelemetry | Not Started | -- | Blocked on Phase 2 design |
| Dashboards and alerting | Not Started | -- | Blocked on telemetry |
| Runbooks | Not Started | -- | Blocked on Phase 2 |
| Support model | Not Started | -- | -- |
| Blue/green deployment | Not Started | -- | Blocked on IaC updates |
| Functional testing | Not Started | -- | Blocked on implementation |
| Performance testing | Not Started | -- | Blocked on implementation |
| Security testing | Not Started | -- | Blocked on implementation |
| DR testing | Not Started | -- | Blocked on deployment |
| Go-live | Not Started | -- | Blocked on all testing |

### Completion Estimate

- **Overall Phase 3 Progress:** 0%
- **Estimated start:** After Phase 1 and Phase 2 substantially complete

---

*Last updated: 2026-03-07*
