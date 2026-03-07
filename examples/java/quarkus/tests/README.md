# Testing Verification Checklist

## Overview

This document provides a step-by-step verification checklist for the Quarkus IAM Resource Server project. It covers the full testing lifecycle from local development through containerized deployment, ensuring that all components function correctly before code is merged or released.

The test strategy is organized into three layers:

- **Unit tests** -- Validate individual components in isolation using `@QuarkusTest` and `@TestSecurity` annotations. No external services are required.
- **Integration tests** -- Verify end-to-end behavior with a real Keycloak instance provisioned automatically by Quarkus Dev Services. Docker must be running.
- **System tests** -- Manual or scripted verification of the containerized application against live endpoints.

## Verification Checklist

| #  | Check                        | Command                                                                                       | Expected Result                                                        |
|----|------------------------------|-----------------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| 1  | Dev mode startup             | `./mvnw quarkus:dev`                                                                          | Application starts on port 8081; Dev UI accessible at `/q/dev`         |
| 2  | Unit tests                   | `./mvnw test`                                                                                 | All unit tests pass; results in `target/surefire-reports/`             |
| 3  | Integration tests            | `./mvnw verify -Pintegration-test`                                                            | All integration tests pass; Keycloak Dev Service starts automatically  |
| 4  | Coverage report              | `./mvnw test jacoco:report`                                                                   | HTML report generated at `target/site/jacoco/index.html`               |
| 5  | Docker build (JVM)           | `docker build -f src/main/docker/Dockerfile.jvm -t iam-quarkus .`                             | Image builds successfully; `docker images` shows `iam-quarkus`         |
| 6  | Docker build (native)        | `docker build -f src/main/docker/Dockerfile.native -t iam-quarkus-native .`                   | Image builds successfully; image size is significantly smaller than JVM |
| 7  | Docker Compose               | `docker-compose up`                                                                           | Keycloak and application start; both containers report healthy          |
| 8  | Health endpoint              | `curl -s http://localhost:8081/api/health`                                                    | Returns `200 OK` with JSON status body                                  |
| 9  | Protected endpoint (auth)    | `curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8081/api/protected`               | Returns `200 OK` with resource payload                                  |
| 10 | Admin role enforcement       | `curl -s -H "Authorization: Bearer $USER_TOKEN" http://localhost:8081/api/admin`              | Returns `403 Forbidden`; only tokens with admin role are accepted       |

## Notes

- For checks 8 through 10, the application and Keycloak must both be running. Obtain tokens as described in the project [README](../README.md#obtain-a-token).
- The `$TOKEN` variable refers to a token with the `admin` realm role. The `$USER_TOKEN` variable refers to a token without the `admin` role.
- Native builds (check 6) require either a local GraalVM installation or a container-based build via `-Dquarkus.native.container-build=true`.
- Integration tests (check 3) rely on Quarkus Dev Services, which automatically provisions a Keycloak container. Ensure Docker has at least 4 GB of memory allocated.
