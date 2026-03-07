# Angular 19 -- IAM-Keycloak Frontend Example

A single-page application built with Angular 19, integrated with Keycloak for identity and access management. The project includes internationalization (i18n), a dark/light theme system, and role-based access control through custom directives.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Project Structure](#project-structure)
4. [Configuration](#configuration)
5. [Running the Application](#running-the-application)
6. [Features](#features)
7. [Testing](#testing)
8. [Verification Checklist](#verification-checklist)
9. [Documentation](#documentation)
10. [Docker](#docker)
11. [Scripts Reference](#scripts-reference)
12. [Troubleshooting](#troubleshooting)

---

## Prerequisites

| Requirement    | Version |
|----------------|---------|
| Node.js        | 22.x    |
| npm             | latest  |
| Angular CLI    | 19.x    |
| Docker Engine   | 24+     |
| Docker Compose  | 2.x     |
| Keycloak        | 26+     |

Install Angular CLI globally if not already present:

```bash
npm install -g @angular/cli@19
```

---

## Quick Start

1. **Start Keycloak**

   ```bash
   docker compose -f ../../infrastructure/docker-compose.yml up -d keycloak
   ```

2. **Configure the Keycloak realm**

   Import the provided realm configuration or create a realm, client, and roles manually. Register `http://localhost:4200/*` as a valid redirect URI.

3. **Install dependencies**

   ```bash
   npm ci
   ```

4. **Set environment variables**

   Edit `src/environments/environment.ts` and `environment.prod.ts` with your Keycloak connection details.

5. **Run the application**

   ```bash
   ng serve
   ```

   Open [http://localhost:4200](http://localhost:4200) in your browser.

---

## Project Structure

```
angular/
├── src/
│   ├── app/
│   │   ├── auth/               # Keycloak integration, guards, interceptors
│   │   ├── components/         # Reusable UI components
│   │   ├── directives/         # Role-based structural directives
│   │   ├── i18n/               # Translation files and i18n configuration
│   │   ├── pages/              # Routed page components
│   │   ├── services/           # Application services
│   │   └── app.config.ts       # Application configuration
│   ├── assets/                 # Static assets
│   ├── environments/           # Environment configuration files
│   └── styles/                 # Global styles, theme custom properties
├── scripts/                    # DevOps helper scripts
├── Dockerfile                  # Multi-stage production build
├── docker-compose.yml          # Local orchestration
├── angular.json                # Angular workspace configuration
└── package.json
```

---

## Configuration

Environment-specific settings are managed in the `src/environments/` directory.

| Property                     | Description                           | Example                                     |
|------------------------------|---------------------------------------|---------------------------------------------|
| `keycloak.issuer`            | Keycloak issuer URL                   | `http://localhost:8080/realms/my-realm`      |
| `keycloak.clientId`          | OAuth 2.0 client identifier           | `angular-app`                               |
| `keycloak.redirectUri`       | Post-login redirect URI               | `http://localhost:4200`                      |
| `keycloak.scope`             | Requested OAuth scopes                | `openid profile email`                      |
| `i18n.defaultLocale`         | Default locale                        | `en`                                        |
| `i18n.supportedLocales`      | List of supported locales             | `["en", "lt", "de"]`                        |

---

## Running the Application

```bash
# Development (with live reload)
ng serve

# Production build
ng build --configuration=production
```

---

## Features

### Internationalization (i18n)

Supported via `@angular/localize` or `ngx-translate`. Translation files are located in `src/app/i18n/` (or `src/locale/` when using `@angular/localize`). Use the `ng extract-i18n` command to extract translatable strings from templates.

### Dark / Light Theme

CSS custom properties define all theme tokens. The application respects the user's operating system preference via `prefers-color-scheme` on first load. A toggle component allows manual override, and the preference is persisted in `localStorage`.

### Role-Based Directives

Custom structural directives (e.g., `*appHasRole="'admin'"`) conditionally render template elements based on the authenticated user's Keycloak roles. Route guards protect pages requiring specific roles.

---

## Testing

### Unit Tests

```bash
ng test
```

Runs the unit test suite using Karma (default) or Jest, depending on project configuration.

### End-to-End Tests

```bash
ng e2e
```

Executes E2E tests using Cypress. Ensure the development server and Keycloak are running before executing E2E tests.

### Coverage Report

```bash
ng test --code-coverage
```

Generates a coverage report in the `coverage/` directory.

---

## Verification Checklist

| Step | Action                                    | Expected Result                                                  |
|------|-------------------------------------------|------------------------------------------------------------------|
| 1    | Open the application root URL             | Redirected to Keycloak login page                                |
| 2    | Log in with valid credentials             | Redirected back to the application; user name displayed          |
| 3    | Check role display                        | Assigned Keycloak roles appear in the user profile section       |
| 4    | Switch language                           | UI labels, headings, and messages update to the selected locale  |
| 5    | Toggle theme                              | Application switches between dark and light themes               |
| 6    | Verify system theme preference            | On first visit, theme matches OS preference                      |
| 7    | Access a role-restricted route as an unauthorized user | Access denied message or redirect                    |
| 8    | Make an authenticated API call            | Request includes Authorization header; response is successful    |
| 9    | Click Logout                              | Session terminated; redirected to login page                     |
| 10   | Verify token refresh                      | Session persists beyond the initial access token lifetime        |

---

## Documentation

Auto-generated project documentation is available via [Compodoc](https://compodoc.app/):

```bash
npm run compodoc
```

This generates comprehensive documentation (components, services, modules, directives, pipes) in the `documentation/` directory. Open `documentation/index.html` in a browser to explore it.

---

## Docker

### Multi-Stage Dockerfile

The included `Dockerfile` uses a multi-stage build:

1. **builder** -- installs dependencies and builds the Angular application.
2. **runner** -- serves the compiled static files via nginx.

### Build and Run

```bash
# Build the image
docker build -t angular-iam .

# Run the container
docker run -p 4200:80 angular-iam
```

### Docker Compose

```bash
docker compose up -d
```

---

## Scripts Reference

| Script              | Command                                    | Description                              |
|---------------------|--------------------------------------------|------------------------------------------|
| `start`             | `ng serve`                                 | Start development server with live reload|
| `build`             | `ng build`                                 | Build the application                    |
| `build:prod`        | `ng build --configuration=production`      | Create optimized production build        |
| `test`              | `ng test`                                  | Run unit tests                           |
| `test:cov`          | `ng test --code-coverage`                  | Run unit tests with coverage             |
| `e2e`               | `ng e2e`                                   | Run end-to-end tests                     |
| `lint`              | `ng lint`                                  | Run linting                              |
| `extract-i18n`      | `ng extract-i18n`                          | Extract translatable strings             |
| `compodoc`          | `npm run compodoc`                         | Generate project documentation           |

---

## Troubleshooting

| Problem                                  | Possible Cause                              | Solution                                                        |
|------------------------------------------|---------------------------------------------|-----------------------------------------------------------------|
| Redirect loop after login                | Redirect URI mismatch                        | Verify the redirect URI in Keycloak client settings             |
| "Invalid redirect_uri" on Keycloak       | URI not registered in the client             | Add `http://localhost:4200` to valid redirect URIs              |
| CORS errors on API calls                 | Keycloak Web Origins misconfigured           | Add the application origin to Keycloak client Web Origins       |
| Theme flashes on page load               | Theme script runs after Angular bootstrap    | Add an inline script in `index.html` to set the theme class     |
| i18n messages not loading                | Missing translation file for the locale      | Verify the translation file exists for the target locale        |
| "ECONNREFUSED" connecting to Keycloak    | Keycloak is not running                      | Start Keycloak and verify the issuer URL                        |
| `ng serve` fails with memory error       | Insufficient heap memory                     | Set `NODE_OPTIONS=--max-old-space-size=4096`                    |
| Angular CLI version mismatch             | Global CLI does not match project version    | Run `npx ng serve` or update the global CLI                     |
