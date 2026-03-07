# Phase 1: Target Architecture - Task Breakdown

> **Phase Duration:** Part of Block A Analysis period (~1.5 months shared with Phase 2 start)
> **Objective:** Define the ideal end-state architecture for the enterprise IAM platform
> **Status:** In Progress

---

## 1. Deliverables Checklist

### 1.1 High-Level Architecture Definition

- [ ] Define end-state system topology diagram (all components, integrations, data flows)
- [ ] Document design principles (security by design, IaC, immutable infrastructure, least privilege, zero trust)
- [ ] Map current architecture components to target architecture
- [ ] Define component responsibilities and boundaries
- [ ] Validate architecture against client constraints (GKE, Oracle DB, Apigee)

### 1.2 Technology Stack Selection and Version Pinning

- [ ] Confirm Red Hat Build of Keycloak target version (based on Keycloak 26.x)
- [ ] Pin Kubernetes version for GKE clusters (Belgium + Madrid)
- [ ] Pin Terraform version and provider versions
- [ ] Pin Helm chart versions for all deployed components
- [ ] Document the selected runtime (e.g., Java 17) requirements for custom microservices such as JIT provisioning and token exchange
- [ ] Confirm Oracle DB version and JDBC driver compatibility with RHBK
- [ ] Document container base image selection (UBI for RHBK)
- [ ] Confirm OpenTelemetry Collector version
- [ ] Confirm Prometheus and Grafana versions
- [ ] Document OPA version and deployment model

### 1.3 Multi-Tenancy Strategy

- [ ] Document realm-per-tenant isolation model
- [ ] Define realm naming conventions
- [ ] Document tenant onboarding process (realm provisioning)
- [ ] Define tenant isolation guarantees (data, network, configuration)
- [ ] Plan for current 2 B2B organizations + future growth
- [ ] Define master/admin realm strategy
- [ ] Document cross-realm considerations (if any)

### 1.4 Network Topology and Namespace Design

- [ ] Define Kubernetes namespace structure for IAM components
- [ ] Document network policies (default deny, explicit allow rules)
- [ ] Define ingress architecture (load balancer, TLS termination)
- [ ] Document DNS strategy (per-tenant endpoints vs shared endpoint)
- [ ] Define multi-region networking between Belgium and Madrid clusters
- [ ] Document Apigee integration points and network paths
- [ ] Define service mesh requirements (if applicable)

### 1.5 High Availability and Disaster Recovery

- [ ] Define HA strategy for Keycloak (replicas, anti-affinity, PDB)
- [ ] Define HA strategy for Oracle DB (client responsibility, but document expectations)
- [ ] Define RPO and RTO targets per component
- [ ] Document multi-region failover strategy (Belgium <-> Madrid)
- [ ] Define backup and restore procedures for Keycloak configuration
- [ ] Document Infinispan/JGroups clustering configuration for multi-region
- [ ] Define session replication strategy across regions

### 1.6 Scalability Considerations

- [ ] Document horizontal scaling strategy (HPA triggers, max replicas)
- [ ] Define vertical scaling baselines (CPU, memory requests/limits)
- [ ] Establish capacity planning targets (~400 users current, growth projections)
- [ ] Document connection pooling strategy for Oracle DB
- [ ] Define rate limiting strategy at ingress and Apigee layers

### 1.7 Integration Architecture

- [ ] Document Apigee integration pattern (API gateway <-> Keycloak)
- [ ] Define JIT microservice integration (federated login flow)
- [ ] Define token exchange microservice integration
- [ ] Document BigQuery integration for audit/analytics
- [ ] Map SAML and OIDC federation flows for B2B organizations
- [ ] Define WAS legacy integration and migration path
- [ ] Document client application integration patterns for all supported frameworks (e.g., Spring Boot, Quarkus, ASP.NET Core, NestJS, Express, FastAPI, Next.js, Angular, React, Vue)

---

## 2. Dependencies

| Task | Depends On | Notes |
|------|-----------|-------|
| Version pinning | Client confirmation of GKE versions and Oracle DB version | Need client input |
| Multi-region networking | Client infrastructure team network topology details | Client manages GKE |
| Oracle DB HA | Client DBA team confirmation of DR setup | Client responsibility |
| Apigee integration | Client Apigee team documentation of current setup | Need existing API gateway config |
| B2B federation details | Client confirmation of current IdP configurations | SAML/OIDC metadata needed |
| WAS legacy path | Client confirmation of WAS decommissioning timeline | Affects integration design |

---

## 3. Key Decisions to Make

| Decision | Options | Recommendation | Status |
|----------|---------|----------------|--------|
| Keycloak DB backend | Oracle DB (existing) vs PostgreSQL (standard) | Oracle DB per client requirement | Decided |
| Multi-region mode | Active-active vs active-passive | TBD -- depends on latency and consistency requirements | Open |
| Session replication | Cross-region Infinispan vs sticky sessions per region | TBD -- needs latency analysis | Open |
| Ingress controller | NGINX vs Istio vs GKE native | TBD -- depends on client existing setup | Open |
| Secret management | Sealed Secrets vs External Secrets Operator vs GCP Secret Manager | TBD -- depends on client preference | Open |
| Container registry | GCR vs Artifact Registry vs external | TBD -- depends on client CI/CD setup | Open |
| RHBK operator vs Helm | Keycloak Operator (RHBK) vs Helm chart deployment | TBD -- evaluate operator maturity | Open |

---

## 4. Reference Documents

| Document | Relevance |
|----------|-----------|
| `doc/00-overview.md` | Project overview, technology stack, document index |
| `doc/01-target-architecture.md` | Current draft of target architecture (needs client-specific updates) |
| `doc/03-multi-tenancy-design.md` | Multi-tenancy deep dive (to be created) |
| `doc/05-infrastructure-as-code.md` | IaC strategy draft (needs GKE/Oracle adaptation) |
| `doc/08-security-hardening.md` | Security controls (to be created) |

**Important:** The existing `doc/01-target-architecture.md` uses PostgreSQL and generic cloud examples. It must be adapted to the client's specific stack: GKE, Oracle DB, Apigee, and the existing microservices (JIT, token exchange).

---

## 5. Status Tracking

| Item | Status | Assignee | Notes |
|------|--------|----------|-------|
| High-level architecture diagram | In Progress | -- | Generic version drafted in doc/01; needs client-specific adaptation |
| Design principles | In Progress | -- | Documented in doc/01 |
| Technology stack | Partial | -- | Generic stack documented; needs Oracle DB, GKE, Apigee specifics |
| Multi-tenancy strategy | Not Started | -- | -- |
| Network topology | Not Started | -- | Awaiting client network details |
| HA/DR strategy | Not Started | -- | Awaiting multi-region details |
| Scalability | Partial | -- | Generic targets in doc/01; needs client workload analysis |
| Integration architecture | Not Started | -- | Critical path -- depends on AS-IS analysis |

### Completion Estimate

- **Overall Phase 1 Progress:** ~20%
- **Blocking items:** Client infrastructure details (GKE config, Oracle DB setup, Apigee config, current Keycloak realm exports)

---

*Last updated: 2026-03-07*
