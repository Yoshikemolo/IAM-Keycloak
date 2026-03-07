# Spring Boot IAM Resource Server

An IAM-integrated resource server built with Spring Boot 3.4 and Java 17. This project demonstrates how to secure REST APIs using Keycloak as the identity provider, with token validation, role-based access control (RBAC), and Open Policy Agent (OPA) integration for fine-grained authorization.

The application follows Clean Architecture principles and is designed as a production-ready starting point for building secure backend services.

## Prerequisites

| Tool       | Version   | Purpose                          |
|------------|-----------|----------------------------------|
| Java       | 17+       | Runtime and compilation          |
| Gradle     | 8.x       | Build tool (wrapper included)    |
| Maven      | 3.9.x     | Alternative build tool           |
| Docker     | 24+       | Containerization and Keycloak    |
| Docker Compose | 2.x   | Multi-container orchestration    |

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
./gradlew bootRun
```

Or with Maven:

```bash
mvn spring-boot:run
```

The application starts on `http://localhost:8081` by default.

## Project Structure

```
src/
  main/
    java/
      com.example.iam/
        config/           # Security configuration, JWT decoder, OPA client
        controller/       # REST controllers (inbound adapters)
        domain/           # Domain entities and business rules
        service/           # Application services (use cases)
        repository/       # Outbound adapters (persistence)
    resources/
      application.yml     # Application configuration
  test/
    java/
      unit/               # Unit tests with MockMvc and @WithMockUser
      integration/        # Integration tests with Testcontainers
```

The project follows Clean Architecture with the following layers:

- **Controller (Adapter)** -- Handles HTTP requests and delegates to services.
- **Service (Use Case)** -- Contains business logic, independent of frameworks.
- **Domain (Entity)** -- Core business entities with no external dependencies.
- **Repository (Adapter)** -- Data access implementations.

## Configuration

### application.yml

The primary configuration file is located at `src/main/resources/application.yml`.

### Environment Variables

| Variable                          | Default                                      | Description                              |
|-----------------------------------|----------------------------------------------|------------------------------------------|
| `SERVER_PORT`                     | `8081`                                       | Application HTTP port                    |
| `KEYCLOAK_BASE_URL`              | `http://localhost:8080`                      | Keycloak server base URL                 |
| `KEYCLOAK_REALM`                 | `tenant`                                     | Keycloak realm name                      |
| `SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI` | `${KEYCLOAK_BASE_URL}/realms/${KEYCLOAK_REALM}` | JWT issuer URI            |
| `SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK_SET_URI` | `${KEYCLOAK_BASE_URL}/realms/${KEYCLOAK_REALM}/protocol/openid-connect/certs` | JWKS endpoint |
| `OPA_URL`                        | `http://localhost:8181/v1/data`              | Open Policy Agent endpoint               |
| `SPRING_PROFILES_ACTIVE`        | `dev`                                        | Active Spring profile                    |

## Running the Application

### With Gradle

```bash
# Development mode with live reload
./gradlew bootRun

# Build the JAR
./gradlew build

# Run the JAR directly
java -jar build/libs/iam-spring-boot-*.jar
```

### With Maven

```bash
# Development mode
mvn spring-boot:run

# Build the JAR
mvn package

# Run the JAR directly
java -jar target/iam-spring-boot-*.jar
```

## Testing

### Unit Tests

Unit tests use MockMvc and `@WithMockUser` to simulate authenticated requests without requiring a running Keycloak instance.

```bash
./gradlew test
```

Or with Maven:

```bash
mvn test
```

### Integration Tests

Integration tests use Testcontainers to spin up a Keycloak instance automatically. Docker must be running.

```bash
./gradlew integrationTest
```

Or with Maven:

```bash
mvn verify -P integration-test
```

### Code Coverage

Generate a JaCoCo coverage report:

```bash
./gradlew jacocoTestReport
```

The HTML report is generated at `build/reports/jacoco/test/html/index.html`.

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

### Build the Image

```bash
docker build -t iam-spring-boot .
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
  iam-spring-boot
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
| Integration tests fail with Docker errors        | Docker not running or Testcontainers issue | Ensure Docker Desktop is running and has sufficient resources          |
| `403 Forbidden` on admin endpoint                | Token lacks required role                  | Use a token from a user/client with the `admin` realm role            |
| Port 8081 already in use                         | Another process on the port                | Change `SERVER_PORT` or stop the conflicting process                  |
| Gradle wrapper not found                         | Missing `gradlew` file                     | Run `gradle wrapper` or use Maven instead                             |
| JaCoCo report is empty                           | Tests did not run before report generation | Run `./gradlew test jacocoTestReport` to execute tests first          |

## Related Documentation

- [Spring Boot Integration Guide](../../../doc/14-01-spring-boot.md)
- [Architecture Overview](../../../doc/01-target-architecture.md)
- [Authentication and Authorization](../../../doc/08-authentication-authorization.md)
