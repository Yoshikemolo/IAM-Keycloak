# Quarkus IAM Resource Server

An IAM-integrated resource server built with Quarkus 3.17 and Java 17. This project demonstrates how to secure REST APIs using Keycloak as the identity provider, with OIDC token validation, role-based access control (RBAC), and Open Policy Agent (OPA) integration for fine-grained authorization.

The application follows Clean Architecture principles and is designed as a production-ready starting point for building secure backend services.

## Prerequisites

| Tool             | Version   | Purpose                                  |
|------------------|-----------|------------------------------------------|
| Java             | 17+       | Runtime and compilation                  |
| Maven            | 3.9.x     | Build tool (wrapper included)            |
| GraalVM          | 23+       | Native image compilation (optional)      |
| Docker           | 24+       | Containerization and Keycloak            |
| Docker Compose   | 2.x       | Multi-container orchestration            |

## Quick Start

### Step 1: Start Keycloak

```bash
cd ../../infra/docker
docker-compose up -d keycloak
```

Keycloak will be available at `http://localhost:8080`. Default admin credentials are `admin` / `admin`.

### Step 2: Configure the Realm

Import the tenant realm configuration:

```bash
# Using the Keycloak Admin CLI or the Admin Console
# Import the realm from ../../keycloak/realms/
```

Alternatively, if the realm auto-imports on startup, verify it is loaded by navigating to `http://localhost:8080/admin` and checking for the tenant realm.

### Step 3: Run the Application

```bash
./mvnw quarkus:dev
```

The application starts on `http://localhost:8081` by default. Quarkus Dev Mode enables live reload and Dev UI at `http://localhost:8081/q/dev`.

## Project Structure

```
src/
  main/
    java/
      com.example.iam/
        config/           # Security configuration, OIDC setup, OPA client
        controller/       # JAX-RS resource classes (inbound adapters)
        domain/           # Domain entities and business rules
        service/          # Application services (use cases)
        repository/       # Outbound adapters (persistence)
    resources/
      application.properties  # Application configuration
    docker/
      Dockerfile.jvm          # JVM-based container image
      Dockerfile.native       # Native executable container image
  test/
    java/
      unit/               # Unit tests with @QuarkusTest and @TestSecurity
      integration/        # Integration tests with Dev Services
```

The project follows Clean Architecture with the following layers:

- **Controller (Adapter)** -- JAX-RS resources that handle HTTP requests and delegate to services.
- **Service (Use Case)** -- Contains business logic, independent of frameworks.
- **Domain (Entity)** -- Core business entities with no external dependencies.
- **Repository (Adapter)** -- Data access implementations.

## Configuration

### application.properties

The primary configuration file is located at `src/main/resources/application.properties`. Quarkus uses a properties-based format by default (YAML is supported via an optional extension).

### Environment Variables

| Variable                                | Default                                                                             | Description                              |
|-----------------------------------------|-------------------------------------------------------------------------------------|------------------------------------------|
| `QUARKUS_HTTP_PORT`                     | `8081`                                                                              | Application HTTP port                    |
| `KEYCLOAK_BASE_URL`                     | `http://localhost:8080`                                                             | Keycloak server base URL                 |
| `KEYCLOAK_REALM`                        | `tenant`                                                                            | Keycloak realm name                      |
| `QUARKUS_OIDC_AUTH_SERVER_URL`          | `${KEYCLOAK_BASE_URL}/realms/${KEYCLOAK_REALM}`                                     | OIDC auth server URL                     |
| `QUARKUS_OIDC_CLIENT_ID`               | `backend-service`                                                                   | OIDC client identifier                   |
| `QUARKUS_OIDC_TOKEN_ISSUER`            | `${KEYCLOAK_BASE_URL}/realms/${KEYCLOAK_REALM}`                                     | Expected token issuer                    |
| `OPA_URL`                               | `http://localhost:8181/v1/data`                                                     | Open Policy Agent endpoint               |
| `QUARKUS_PROFILE`                       | `dev`                                                                               | Active Quarkus profile                   |

## Running the Application

### Maven Dev Mode

```bash
# Development mode with live reload and Dev UI
./mvnw quarkus:dev
```

### Build Uber-Jar

```bash
# Build the uber-jar
./mvnw package -Dquarkus.package.jar.type=uber-jar

# Run the uber-jar directly
java -jar target/iam-quarkus-runner.jar
```

### Native Build

```bash
# Build a native executable (requires GraalVM or container-based build)
./mvnw package -Dnative

# Container-based native build (no local GraalVM required)
./mvnw package -Dnative -Dquarkus.native.container-build=true

# Run the native executable
./target/iam-quarkus-runner
```

## Testing

### Unit Tests

Unit tests use `@QuarkusTest` and `@TestSecurity` to simulate authenticated requests without requiring a running Keycloak instance.

```bash
./mvnw test
```

### Integration Tests

Integration tests use Quarkus Dev Services to automatically provision a Keycloak instance. Docker must be running.

```bash
./mvnw verify -Pintegration-test
```

### Code Coverage

Generate a JaCoCo coverage report:

```bash
./mvnw jacoco:report
```

The HTML report is generated at `target/site/jacoco/index.html`.

### Verification

After starting the application, verify the endpoints using the following commands. Replace `<TOKEN>` with a valid access token obtained from Keycloak.

#### Obtain a Token

```bash
TOKEN=$(curl -s -X POST "http://localhost:8080/realms/tenant/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=backend-service" \
  -d "client_secret=your-client-secret" | jq -r '.access_token')
```

#### Test Endpoints

| Endpoint               | Method | Command                                                                                          | Expected Response          |
|------------------------|--------|--------------------------------------------------------------------------------------------------|----------------------------|
| `GET /api/health`      | GET    | `curl -s http://localhost:8081/api/health`                                                       | `200 OK` with status body  |
| `GET /api/public`      | GET    | `curl -s http://localhost:8081/api/public`                                                       | `200 OK` (no auth needed)  |
| `GET /api/protected`   | GET    | `curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8081/api/protected`                  | `200 OK` with resource     |
| `GET /api/admin`       | GET    | `curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8081/api/admin`                      | `200 OK` (admin role)      |
| `GET /api/protected`   | GET    | `curl -s http://localhost:8081/api/protected`                                                    | `401 Unauthorized`         |
| `GET /api/admin`       | GET    | `curl -s -H "Authorization: Bearer $USER_TOKEN" http://localhost:8081/api/admin`                 | `403 Forbidden`            |

## Docker

### Build the Image (JVM)

```bash
docker build -f src/main/docker/Dockerfile.jvm -t iam-quarkus .
```

### Build the Image (Native)

```bash
docker build -f src/main/docker/Dockerfile.native -t iam-quarkus-native .
```

### Run with Docker Compose

```bash
docker-compose up
```

This starts Keycloak and the application together. The Docker Compose file defines service dependencies so Keycloak starts first.

### Run Standalone

```bash
docker run -p 8081:8081 \
  -e KEYCLOAK_BASE_URL=http://host.docker.internal:8080 \
  iam-quarkus
```

## Scripts

An interactive DevOps menu script is available for common operations:

```bash
./scripts/devops-menu.sh
```

See [scripts/devops-menu.sh](scripts/devops-menu.sh) for the full list of available operations.

## Troubleshooting

| Problem                                          | Cause                                      | Solution                                                              |
|--------------------------------------------------|--------------------------------------------|-----------------------------------------------------------------------|
| `401 Unauthorized` on all protected endpoints    | Invalid or expired token                   | Obtain a fresh token from Keycloak                                    |
| `Connection refused` to Keycloak                 | Keycloak not running                       | Run `docker-compose up -d keycloak` in `../../infra/docker`           |
| `Invalid issuer` error in logs                   | Issuer URI mismatch                        | Ensure `KEYCLOAK_BASE_URL` and `KEYCLOAK_REALM` match your setup      |
| Integration tests fail with Docker errors        | Docker not running or Dev Services issue   | Ensure Docker Desktop is running and has sufficient resources          |
| `403 Forbidden` on admin endpoint                | Token lacks required role                  | Use a token from a user/client with the `admin` realm role            |
| Port 8081 already in use                         | Another process on the port                | Change `QUARKUS_HTTP_PORT` or stop the conflicting process            |
| Maven wrapper not found                          | Missing `mvnw` file                        | Run `mvn wrapper:wrapper` or install Maven system-wide                |
| JaCoCo report is empty                           | Tests did not run before report generation | Run `./mvnw test jacoco:report` to execute tests first                |
| Native build fails with memory errors            | Insufficient memory for GraalVM            | Increase Docker/system memory or use `-Dquarkus.native.container-build=true` |

## Related Documentation

- [Quarkus Integration Guide](../../../doc/14-02-quarkus.md)
- [Architecture Overview](../../../doc/01-target-architecture.md)
- [Authentication and Authorization](../../../doc/08-authentication-authorization.md)
