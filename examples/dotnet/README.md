# ASP.NET Core IAM Resource Server

An IAM-integrated resource server built with ASP.NET Core on .NET 9. This project demonstrates how to secure REST APIs using Keycloak as the identity provider, with JWT token validation, role-based access control (RBAC), and Open Policy Agent (OPA) integration for fine-grained authorization.

The application follows Clean Architecture principles and is designed as a production-ready starting point for building secure backend services in C#.

## Prerequisites

| Tool             | Version | Purpose                          |
|------------------|---------|----------------------------------|
| .NET SDK         | 9.0+    | Build and runtime                |
| Docker           | 24+     | Containerization and Keycloak    |
| Docker Compose   | 2.x     | Multi-container orchestration    |

## Quick Start

### Step 1: Start Keycloak

```bash
cd ../infra/docker
docker-compose up -d keycloak
```

Keycloak will be available at `http://localhost:8080`. Default admin credentials are `admin` / `admin`.

### Step 2: Configure the Realm

Import the tenant realm configuration from `../keycloak/realms/` using the Keycloak Admin Console or CLI.

### Step 3: Run the Application

```bash
cd src
dotnet run
```

The application starts on `http://localhost:5000` by default.

## Project Structure

```
src/
  Controllers/        # API controllers (inbound adapters)
  Domain/             # Domain entities and business rules
  Services/           # Application services (use cases)
  Infrastructure/     # Data access, external service clients
  Configuration/      # Security, JWT, and OPA configuration
  Program.cs          # Application entry point and DI setup
  appsettings.json    # Application configuration
tests/
  Unit/               # Unit tests with WebApplicationFactory
  Integration/        # Integration tests with Testcontainers
```

The project follows Clean Architecture with the following layers:

- **Controllers (Adapter)** -- Handle HTTP requests and delegate to services.
- **Services (Use Case)** -- Contain business logic, independent of frameworks.
- **Domain (Entity)** -- Core business entities with no external dependencies.
- **Infrastructure (Adapter)** -- Data access and external service implementations.

## Configuration

### appsettings.json

The primary configuration file is located at `src/appsettings.json`.

### Environment Variables

| Variable                        | Default                                        | Description                              |
|---------------------------------|------------------------------------------------|------------------------------------------|
| `ASPNETCORE_URLS`              | `http://+:5000`                                | Application listen URLs                  |
| `ASPNETCORE_ENVIRONMENT`       | `Development`                                  | Runtime environment                      |
| `Keycloak__BaseUrl`            | `http://localhost:8080`                        | Keycloak server base URL                 |
| `Keycloak__Realm`              | `tenant`                                       | Keycloak realm name                      |
| `Keycloak__Authority`          | `${BaseUrl}/realms/${Realm}`                   | JWT authority / issuer URI               |
| `Keycloak__Audience`           | `account`                                      | Expected token audience                  |
| `Opa__Url`                     | `http://localhost:8181/v1/data`                | Open Policy Agent endpoint               |

## Running the Application

```bash
# Development mode with hot reload
cd src
dotnet watch run

# Standard run
dotnet run --project src

# Publish a release build
dotnet publish src -c Release -o ./publish
dotnet ./publish/IamDotnet.dll
```

## Testing

### Unit Tests

Unit tests use xUnit and `WebApplicationFactory` to test endpoints in-memory without requiring external services.

```bash
dotnet test
```

### Integration Tests

Integration tests use Testcontainers to spin up a Keycloak instance automatically. Docker must be running.

```bash
dotnet test --filter "Category=Integration"
```

### Code Coverage

Generate code coverage reports using Coverlet:

```bash
dotnet test --collect:"XPlat Code Coverage"
```

Coverage results are written to `tests/TestResults/`. To generate an HTML report, use ReportGenerator:

```bash
dotnet tool install -g dotnet-reportgenerator-globaltool
reportgenerator -reports:tests/TestResults/**/coverage.cobertura.xml -targetdir:tests/CoverageReport -reporttypes:Html
```

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
| `GET /api/health`      | GET    | `curl -s http://localhost:5000/api/health`                                                       | `200 OK` with status body  |
| `GET /api/public`      | GET    | `curl -s http://localhost:5000/api/public`                                                       | `200 OK` (no auth needed)  |
| `GET /api/protected`   | GET    | `curl -s -H "Authorization: Bearer $TOKEN" http://localhost:5000/api/protected`                  | `200 OK` with resource     |
| `GET /api/admin`       | GET    | `curl -s -H "Authorization: Bearer $TOKEN" http://localhost:5000/api/admin`                      | `200 OK` (admin role)      |
| `GET /api/protected`   | GET    | `curl -s http://localhost:5000/api/protected`                                                    | `401 Unauthorized`         |
| `GET /api/admin`       | GET    | `curl -s -H "Authorization: Bearer $USER_TOKEN" http://localhost:5000/api/admin`                 | `403 Forbidden`            |

## Docker

### Build the Image

```bash
docker build -t iam-dotnet .
```

### Run with Docker Compose

```bash
docker-compose up
```

This starts Keycloak and the application together.

### Run Standalone

```bash
docker run -p 5000:5000 \
  -e Keycloak__BaseUrl=http://host.docker.internal:8080 \
  iam-dotnet
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
| `Connection refused` to Keycloak                 | Keycloak not running                       | Run `docker-compose up -d keycloak` in `../infra/docker`              |
| `Bearer error="invalid_token"` in response       | Issuer or audience mismatch                | Verify `Keycloak__Authority` and `Keycloak__Audience` settings        |
| Integration tests fail with Docker errors        | Docker not running or Testcontainers issue | Ensure Docker Desktop is running and has sufficient resources          |
| `403 Forbidden` on admin endpoint                | Token lacks required role                  | Use a token from a user/client with the `admin` realm role            |
| Port 5000 already in use                         | Another process on the port                | Change `ASPNETCORE_URLS` or stop the conflicting process              |
| `dotnet: command not found`                      | .NET SDK not installed                     | Install the .NET 9 SDK from https://dot.net                           |
| Coverage report is empty                         | Coverlet package not referenced            | Add `coverlet.collector` NuGet package to the test project            |

## Related Documentation

- [ASP.NET Core Integration Guide](../../doc/14-02-dotnet.md)
- [Architecture Overview](../../doc/01-target-architecture.md)
- [Authentication and Authorization](../../doc/08-authentication-authorization.md)
