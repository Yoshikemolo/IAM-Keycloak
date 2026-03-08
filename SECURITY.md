# Security Policy

## Supported Versions

This repository is actively maintained in the `main` and `dev` branches.

- `main`: Supported for production-ready fixes and security patches
- `dev`: Supported for upcoming releases and active development
- Older release branches (if any): Best effort only, unless explicitly stated

## Reporting a Vulnerability

If you discover a security vulnerability, please do **not** open a public issue.

Use responsible disclosure:

1. Send an email to `security@ximplicity.com` with the subject `Security Disclosure - IAM-Keycloak`.
2. Include a clear description, reproduction steps, potential impact, and affected components.
3. If available, include a proof of concept, logs, and suggested mitigation.

You can optionally include a PGP key for encrypted follow-up communication.

## What to Include in the Report

Please provide as much detail as possible:

- Vulnerability type (authentication bypass, privilege escalation, token leakage, etc.)
- Exact location (file path, module, endpoint, infrastructure component)
- Preconditions and attack scenario
- Reproduction steps
- Expected vs actual behavior
- Impact assessment (confidentiality, integrity, availability)
- Proposed fix or workaround (if known)

## Response Process

Our process is:

1. **Acknowledgment** within 3 business days.
2. **Triage** and severity assessment.
3. **Validation** and remediation planning.
4. **Fix development** and testing.
5. **Coordinated disclosure** after patch availability.

Target remediation windows (guideline):

- Critical: 7 days
- High: 14 days
- Medium: 30 days
- Low: 60 days

Timelines may vary depending on complexity and dependency constraints.

## Disclosure and Credit

We support coordinated vulnerability disclosure and will credit reporters (if desired) once a fix is available and safe to publish.

## Scope

This policy applies to:

- Keycloak configuration, themes, and custom providers
- Infrastructure code (Terraform, Kubernetes, Helm, Docker)
- Example backend and frontend integrations
- CI/CD and automation scripts in this repository

Out of scope:

- Vulnerabilities that only affect unsupported third-party versions
- Theoretical findings without reproducible impact
- Denial-of-service reports requiring unrealistic resource assumptions

## Safe Harbor

We will not pursue legal action against security researchers who:

- Act in good faith
- Avoid privacy violations, data destruction, and service disruption
- Give us reasonable time to remediate before public disclosure
