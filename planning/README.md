# IAM Keycloak Project - Planning Documentation

## Purpose

This folder contains all planning and tracking documents for the Enterprise IAM Keycloak project. These documents are designed to serve as a persistent context layer so that any team member -- or an AI assistant -- can resume work across different sessions without losing continuity.

Every planning document captures not only what needs to be done, but also what has been decided, what is in progress, and what remains open. This enables effective handoffs and asynchronous collaboration.

---

## How to Use These Documents to Resume Work

1. **Start here.** Read this README for the current project status and key decisions.
2. **Check progress.** Open [progress-tracker.md](./progress-tracker.md) to see the latest milestone status, session log, and open questions.
3. **Review context.** If you need full background, read [project-context.md](./project-context.md) for the complete project history, stakeholder information, and technical details.
4. **Pick up a phase.** Open the relevant phase document ([phase-1-target-architecture.md](./phase-1-target-architecture.md), [phase-2-analysis-design.md](./phase-2-analysis-design.md), or [phase-3-execution.md](./phase-3-execution.md)) to see the current checklist and identify the next task.
5. **Log your work.** After completing work, update the relevant phase document checkboxes, add an entry to the session log in [progress-tracker.md](./progress-tracker.md), and record any new decisions or risks.

---

## Planning Files Index

| File | Description |
|------|-------------|
| [README.md](./README.md) | This file -- planning overview and quick reference |
| [project-context.md](./project-context.md) | Complete project context: client, provider, RFP, technical details, strategic decisions |
| [phase-1-target-architecture.md](./phase-1-target-architecture.md) | Phase 1 task breakdown: target architecture definition |
| [phase-2-analysis-design.md](./phase-2-analysis-design.md) | Phase 2 task breakdown: analysis and design activities |
| [phase-3-execution.md](./phase-3-execution.md) | Phase 3 task breakdown: transformation, migration, go-live |
| [progress-tracker.md](./progress-tracker.md) | Milestones, document status, decision log, risk register, session log |

## Related Documentation

The `doc/` folder contains the technical documentation set (documents 00 through 14):

| Document | Status |
|----------|--------|
| [doc/00-overview.md](../doc/00-overview.md) | Drafted |
| [doc/01-target-architecture.md](../doc/01-target-architecture.md) | Drafted |
| [doc/02-analysis-and-design.md](../doc/02-analysis-and-design.md) | Drafted |
| [doc/03-transformation-execution.md](../doc/03-transformation-execution.md) | Drafted |
| [doc/04-keycloak-configuration.md](../doc/04-keycloak-configuration.md) | Drafted |
| [doc/05-infrastructure-as-code.md](../doc/05-infrastructure-as-code.md) | Drafted |
| [doc/06-cicd-pipelines.md](../doc/06-cicd-pipelines.md) | Drafted |
| [doc/07-security-by-design.md](../doc/07-security-by-design.md) | Drafted |
| [doc/08-authentication-authorization.md](../doc/08-authentication-authorization.md) | Drafted |
| [doc/09-user-lifecycle.md](../doc/09-user-lifecycle.md) | Drafted |
| [doc/10-observability.md](../doc/10-observability.md) | Drafted |
| [doc/11-keycloak-customization.md](../doc/11-keycloak-customization.md) | Drafted |
| [doc/12-environment-management.md](../doc/12-environment-management.md) | Drafted |
| [doc/13-automation-scripts.md](../doc/13-automation-scripts.md) | Drafted |
| [doc/14-client-applications.md](../doc/14-client-applications.md) | Drafted |
| [doc/14-01](../doc/14-01-spring-boot.md) through [doc/14-10](../doc/14-10-quarkus.md) | Drafted (10 per-framework integration guides) |
| [doc/15-multi-tenancy-design.md](../doc/15-multi-tenancy-design.md) | Drafted |
| [doc/16-operations-runbook.md](../doc/16-operations-runbook.md) | Drafted |
| [doc/17-disaster-recovery.md](../doc/17-disaster-recovery.md) | Drafted |
| [doc/18-testing-strategy.md](../doc/18-testing-strategy.md) | Drafted |
| [doc/19-migration-strategy.md](../doc/19-migration-strategy.md) | Drafted |
| [doc/20-compliance-governance.md](../doc/20-compliance-governance.md) | Drafted |

---

## Current Project Status

**Phase 0 - Documentation and Planning**

The project is currently in a pre-execution documentation and planning phase. The RFP has been analyzed, the proposal has been submitted, and initial technical documentation has begun. No implementation work has started.

### What Has Been Completed

- RFP analysis and response (proposal submitted)
- Questions sent to client and answers received
- Full documentation set drafted (documents 00 through 20, including 10 per-framework integration guides 14-01 through 14-10)
- Planning folder and tracking documents created
- Example project scaffolding for all supported frameworks (README, devops-menu.sh, tests)

### What Is In Progress

- Refining target architecture to match client-specific infrastructure (GKE, Oracle DB, Apigee)
- Populating example project source code (Clean Architecture, full documentation comments)

### What Is Next

- Finalize Phase 1 deliverables (target architecture documentation)
- Begin AS-IS analysis of the existing Keycloak deployment
- Schedule kickoff with client infrastructure team
- Create devops/quick-start.sh interactive launcher
- Create Dockerfiles and docker-compose.yml for each example project

---

## Quick Reference: Key Decisions Made

| Decision | Rationale | Date |
|----------|-----------|------|
| L3 support only positioning | Ximplicity provides deep Keycloak expertise; client team handles L1/L2 and infrastructure | Pre-contract |
| Hybrid support model | Combination of remote and on-site as needed | Pre-contract |
| Realm-per-tenant multi-tenancy | Standard Keycloak isolation pattern; each tenant gets a dedicated realm | Architecture phase |
| Red Hat Build of Keycloak as target | Client requirement for enterprise support and certified builds | RFP requirement |
| Oracle DB as Keycloak backend | Client existing infrastructure; not PostgreSQL as in generic architecture docs | RFP clarification |
| GKE multi-region (Belgium + Madrid) | Client existing infrastructure on Google Cloud | RFP clarification |
| Three-phase delivery model | Target Architecture, Analysis and Design, Transformation/Execution | RFP structure |
| Block A (4 months) + Block B (8 months) | Project delivery followed by operational support period | RFP structure |

---

*This document was created on 2026-03-07. Update this file whenever the project status or key decisions change.*
