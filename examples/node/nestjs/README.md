# NestJS IAM Resource Server

An IAM-integrated resource server built with NestJS 10 and TypeScript. This project demonstrates how to secure REST APIs using Keycloak as the identity provider, with JWT token validation, role-based access control (RBAC), and Open Policy Agent (OPA) integration for fine-grained authorization.

The application follows Clean Architecture principles with NestJS modules and is designed as a production-ready starting point for building secure backend services in TypeScript.

## Prerequisites

| Tool             | Version | Purpose                          |
|------------------|---------|----------------------------------|
| Node.js          | 22.x    | Runtime                          |
| npm or pnpm      | 10.x+   | Package management               |
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

### Step 3: Install Dependencies and Run

```bash
npm ci
npm run start:dev
```

The application starts on `http://localhost:3000` by default.

## Project Structure

```
src/
  auth/               # Authentication module (JWT strategy, guards)
  config/             # Configuration module (env validation, typed config)
  resources/          # Resource module (controllers, services, DTOs)
  telemetry/          # OpenTelemetry instrumentation module
  app.module.ts       # Root application module
  main.ts             # Application entry point
test/
  unit/               # Unit tests
  e2e/                # End-to-end tests with supertest
```

The project follows Clean Architecture with the following layers:

- **Controllers (Adapter)** -- Handle HTTP requests, apply guards and decorators.
- **Services (Use Case)** -- Contain business logic, injected via NestJS DI.
- **Domain (Entity)** -- Core business entities and interfaces.
- **Guards and Strategies (Adapter)** -- JWT validation and role enforcement.

## Configuration

### Environment Variables

| Variable                | Default                                      | Description                              |
|-------------------------|----------------------------------------------|------------------------------------------|
| `PORT`                  | `3000`                                       | Application HTTP port                    |
| `KEYCLOAK_BASE_URL`    | `http://localhost:8080`                      | Keycloak server base URL                 |
| `KEYCLOAK_REALM`       | `tenant`                                     | Keycloak realm name                      |
| `KEYCLOAK_JWKS_URI`    | `${KEYCLOAK_BASE_URL}/realms/${KEYCLOAK_REALM}/protocol/openid-connect/certs` | JWKS endpoint |
| `KEYCLOAK_ISSUER`      | `${KEYCLOAK_BASE_URL}/realms/${KEYCLOAK_REALM}` | Expected JWT issuer                   |
| `OPA_URL`              | `http://localhost:8181/v1/data`              | Open Policy Agent endpoint               |
| `NODE_ENV`             | `development`                                | Runtime environment                      |

## Running the Application

```bash
# Development mode with hot reload
npm run start:dev

# Production mode
npm run build
npm run start:prod

# Debug mode
npm run start:debug
```

## Testing

### Unit Tests

Unit tests use Jest to test individual services, controllers, and guards in isolation.

```bash
npm test
```

To run in watch mode:

```bash
npm run test:watch
```

### End-to-End Tests

E2E tests use supertest and a test module to spin up the full application and make HTTP requests.

```bash
npm run test:e2e
```

### Code Coverage

Generate a coverage report with Istanbul/Jest:

```bash
npm run test:cov
```

The HTML report is generated at `coverage/lcov-report/index.html`.

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
| `GET /api/health`      | GET    | `curl -s http://localhost:3000/api/health`                                                       | `200 OK` with status body  |
| `GET /api/public`      | GET    | `curl -s http://localhost:3000/api/public`                                                       | `200 OK` (no auth needed)  |
| `GET /api/protected`   | GET    | `curl -s -H "Authorization: Bearer $TOKEN" http://localhost:3000/api/protected`                  | `200 OK` with resource     |
| `GET /api/admin`       | GET    | `curl -s -H "Authorization: Bearer $TOKEN" http://localhost:3000/api/admin`                      | `200 OK` (admin role)      |
| `GET /api/protected`   | GET    | `curl -s http://localhost:3000/api/protected`                                                    | `401 Unauthorized`         |
| `GET /api/admin`       | GET    | `curl -s -H "Authorization: Bearer $USER_TOKEN" http://localhost:3000/api/admin`                 | `403 Forbidden`            |

## Documentation

Generate API documentation with Compodoc:

```bash
npm run doc
```

The documentation is generated at `documentation/index.html` and can be served locally.

## Docker

### Build the Image

```bash
docker build -t iam-nestjs .
```

### Run with Docker Compose

```bash
docker-compose up
```

### Run Standalone

```bash
docker run -p 3000:3000 \
  -e KEYCLOAK_BASE_URL=http://host.docker.internal:8080 \
  iam-nestjs
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
| `UnauthorizedException: Invalid token`           | JWKS URI or issuer mismatch                | Verify `KEYCLOAK_JWKS_URI` and `KEYCLOAK_ISSUER` settings            |
| E2E tests timeout                                | Application startup too slow               | Increase Jest timeout in test config                                  |
| `403 Forbidden` on admin endpoint                | Token lacks required role                  | Use a token from a user/client with the `admin` realm role            |
| Port 3000 already in use                         | Another process on the port                | Change `PORT` or stop the conflicting process                         |
| `npm ci` fails                                   | Node.js version mismatch                   | Ensure Node.js 22.x is installed; check with `node --version`         |
| Compodoc generation fails                        | Missing dev dependency                     | Run `npm install @compodoc/compodoc --save-dev`                       |

## Related Documentation

- [NestJS Integration Guide](../../../doc/14-03-nestjs.md)
- [Architecture Overview](../../../doc/01-target-architecture.md)
- [Authentication and Authorization](../../../doc/08-authentication-authorization.md)
