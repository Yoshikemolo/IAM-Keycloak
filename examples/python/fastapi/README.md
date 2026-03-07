# FastAPI IAM Resource Server

An IAM-integrated resource server built with FastAPI and Python 3.12. This project demonstrates how to secure REST APIs using Keycloak as the identity provider, with JWT token validation, role-based access control (RBAC), and Open Policy Agent (OPA) integration for fine-grained authorization.

The application follows a clean layered architecture and is designed as a production-ready starting point for building secure backend services in Python.

## Prerequisites

| Tool             | Version | Purpose                          |
|------------------|---------|----------------------------------|
| Python           | 3.12+   | Runtime                          |
| pip or Poetry    | latest  | Package management               |
| Docker           | 24+     | Containerization and Keycloak    |
| Docker Compose   | 2.x     | Multi-container orchestration    |

## Quick Start

### Step 1: Start Keycloak

```bash
cd ../../infra/docker
docker-compose up -d keycloak
```

Keycloak will be available at `http://localhost:8080`. Default admin credentials are `admin` / `admin`.

### Step 2: Configure the Realm

Import the tenant realm configuration from `../../keycloak/realms/` using the Keycloak Admin Console or CLI.

### Step 3: Set Up and Run

```bash
python -m venv .venv
source .venv/bin/activate    # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

The application starts on `http://localhost:8000` by default.

## Project Structure

```
app/
  auth/               # JWT verification, token dependencies, role guards
  routers/            # API route definitions (FastAPI routers)
  telemetry/          # OpenTelemetry instrumentation
  main.py             # FastAPI application factory and middleware setup
  config.py           # Pydantic settings and environment configuration
  models.py           # Domain models and Pydantic schemas
  services.py         # Business logic / use case layer
tests/
  unit/               # Unit tests with pytest
  integration/        # Integration tests with httpx / TestClient
  conftest.py         # Shared fixtures
```

The project follows a layered architecture:

- **Routers (Adapter)** -- Handle HTTP requests using FastAPI dependency injection.
- **Services (Use Case)** -- Contain business logic, framework-independent.
- **Models (Entity)** -- Pydantic models for validation and domain representation.
- **Auth (Adapter)** -- Token verification and role-based access dependencies.

## Configuration

### Environment Variables

| Variable                | Default                                      | Description                              |
|-------------------------|----------------------------------------------|------------------------------------------|
| `PORT`                  | `8000`                                       | Application HTTP port                    |
| `KEYCLOAK_BASE_URL`    | `http://localhost:8080`                      | Keycloak server base URL                 |
| `KEYCLOAK_REALM`       | `tenant`                                     | Keycloak realm name                      |
| `KEYCLOAK_JWKS_URI`    | `${KEYCLOAK_BASE_URL}/realms/${KEYCLOAK_REALM}/protocol/openid-connect/certs` | JWKS endpoint |
| `KEYCLOAK_ISSUER`      | `${KEYCLOAK_BASE_URL}/realms/${KEYCLOAK_REALM}` | Expected JWT issuer                   |
| `OPA_URL`              | `http://localhost:8181/v1/data`              | Open Policy Agent endpoint               |
| `ENV`                  | `development`                                | Runtime environment                      |

Configuration can also be provided via a `.env` file in the project root, which is loaded automatically by Pydantic Settings.

## Running the Application

```bash
# Development mode with auto-reload
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Production mode with multiple workers
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4

# Using Poetry (if configured)
poetry run uvicorn app.main:app --reload
```

## OpenAPI Documentation

FastAPI automatically generates interactive API documentation. Once the application is running:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json

You can use the Swagger UI to test endpoints directly in the browser, including the "Authorize" button to provide a Bearer token.

## Testing

### Unit Tests

Unit tests use pytest with FastAPI's `TestClient` to test endpoints without requiring external services.

```bash
pytest
```

To run only unit tests:

```bash
pytest tests/unit
```

### Integration Tests

Integration tests verify behavior against real or containerized Keycloak instances.

```bash
pytest tests/integration
```

### Code Coverage

Generate a coverage report with pytest-cov:

```bash
pytest --cov=app --cov-report=html
```

The HTML report is generated at `htmlcov/index.html`.

### Verification

After starting the application, verify the endpoints using the following commands.

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
| `GET /api/health`      | GET    | `curl -s http://localhost:8000/api/health`                                                       | `200 OK` with status body  |
| `GET /api/public`      | GET    | `curl -s http://localhost:8000/api/public`                                                       | `200 OK` (no auth needed)  |
| `GET /api/protected`   | GET    | `curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8000/api/protected`                  | `200 OK` with resource     |
| `GET /api/admin`       | GET    | `curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8000/api/admin`                      | `200 OK` (admin role)      |
| `GET /api/protected`   | GET    | `curl -s http://localhost:8000/api/protected`                                                    | `401 Unauthorized`         |
| `GET /api/admin`       | GET    | `curl -s -H "Authorization: Bearer $USER_TOKEN" http://localhost:8000/api/admin`                 | `403 Forbidden`            |

You can also use the Swagger UI at `http://localhost:8000/docs` to test endpoints interactively.

## Docker

### Build the Image

```bash
docker build -t iam-fastapi .
```

### Run with Docker Compose

```bash
docker-compose up
```

### Run Standalone

```bash
docker run -p 8000:8000 \
  -e KEYCLOAK_BASE_URL=http://host.docker.internal:8080 \
  iam-fastapi
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
| `JWKError` or `InvalidTokenError`                | JWKS URI or issuer mismatch                | Verify `KEYCLOAK_JWKS_URI` and `KEYCLOAK_ISSUER` settings            |
| `ModuleNotFoundError`                            | Dependencies not installed                 | Run `pip install -r requirements.txt` in the virtual environment      |
| `403 Forbidden` on admin endpoint                | Token lacks required role                  | Use a token from a user/client with the `admin` realm role            |
| Port 8000 already in use                         | Another process on the port                | Change `PORT` or stop the conflicting process                         |
| `python: command not found`                      | Python not installed or not in PATH        | Install Python 3.12+ and ensure it is on PATH                         |
| Coverage report is empty                         | pytest-cov not installed                   | Run `pip install pytest-cov`                                          |

## Related Documentation

- [FastAPI Integration Guide](../../../doc/14-05-python-fastapi.md)
- [Architecture Overview](../../../doc/01-target-architecture.md)
- [Authentication and Authorization](../../../doc/08-authentication-authorization.md)
