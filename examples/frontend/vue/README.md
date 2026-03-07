# Vue 3.5 -- IAM-Keycloak Frontend Example

A single-page application built with Vue 3.5 and Vite, integrated with Keycloak for identity and access management. The project features internationalization (i18n) via vue-i18n, a dark/light theme system, Pinia-based authentication state management, and role-based rendering directives.

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
9. [Docker](#docker)
10. [Scripts Reference](#scripts-reference)
11. [Troubleshooting](#troubleshooting)

---

## Prerequisites

| Requirement    | Version |
|----------------|---------|
| Node.js        | 22.x    |
| npm             | latest  |
| Docker Engine   | 24+     |
| Docker Compose  | 2.x     |
| Keycloak        | 26+     |

---

## Quick Start

1. **Start Keycloak**

   ```bash
   docker compose -f ../../infrastructure/docker-compose.yml up -d keycloak
   ```

2. **Configure the Keycloak realm**

   Import the provided realm configuration or create a realm, client, and roles manually. Register `http://localhost:5173/*` as a valid redirect URI.

3. **Install dependencies**

   ```bash
   npm ci
   ```

4. **Set environment variables**

   Copy `.env.example` to `.env.local` and populate the values (see [Configuration](#configuration)).

5. **Run the application**

   ```bash
   npm run dev
   ```

   Open [http://localhost:5173](http://localhost:5173) in your browser.

---

## Project Structure

```
vue/
├── src/
│   ├── auth/               # Keycloak plugin, composables, utilities
│   ├── components/         # Reusable UI components
│   ├── composables/        # Vue composables (hooks)
│   ├── directives/         # Custom directives (v-has-role, etc.)
│   ├── i18n/               # vue-i18n configuration and locale files
│   ├── pages/              # Page-level components
│   ├── router/             # Vue Router configuration and guards
│   ├── stores/             # Pinia stores (auth store, theme store)
│   ├── styles/             # Global CSS, theme custom properties
│   ├── App.vue             # Root component
│   └── main.ts             # Application entry point
├── public/                 # Static assets
├── scripts/                # DevOps helper scripts
├── Dockerfile              # Multi-stage production build
├── docker-compose.yml      # Local orchestration
├── vite.config.ts          # Vite configuration
└── package.json
```

---

## Configuration

All configuration is managed through environment variables. Create a `.env.local` file in the project root.

| Variable                          | Description                           | Default / Example                          |
|-----------------------------------|---------------------------------------|--------------------------------------------|
| `VITE_KEYCLOAK_URL`              | Keycloak base URL                     | `http://localhost:8080`                     |
| `VITE_KEYCLOAK_REALM`           | Keycloak realm name                   | `my-realm`                                 |
| `VITE_KEYCLOAK_CLIENT_ID`       | OAuth 2.0 client identifier           | `vue-app`                                  |
| `VITE_DEFAULT_LOCALE`           | Default locale for i18n               | `en`                                       |

---

## Running the Application

```bash
# Development (with hot module replacement)
npm run dev

# Production build
npm run build

# Preview production build locally
npm run preview
```

---

## Features

### Internationalization (i18n)

Powered by **vue-i18n**. Locale message files reside in `src/i18n/locales/`. The Composition API (`useI18n`) is used throughout the application. Language switching is available through a UI selector and the active locale is persisted in `localStorage`.

### Dark / Light Theme

CSS custom properties define theme tokens. The default theme follows the user's operating system preference via `prefers-color-scheme`. A toggle component allows manual override. Theme state is managed in a Pinia store and persisted in `localStorage`.

### Pinia Auth Store

The authentication state (user profile, roles, token) is managed centrally in a Pinia store (`src/stores/auth.ts`). The store provides actions for login, logout, and token refresh, and getters for role checks.

### Role-Based Directives

Custom Vue directives (e.g., `v-has-role="'admin'"`) conditionally render elements based on the authenticated user's Keycloak roles. Navigation guards protect routes requiring specific roles.

---

## Testing

### Unit Tests

```bash
npm test
```

Runs the unit test suite using Vitest with Vue Test Utils.

### End-to-End Tests

```bash
npm run test:e2e
```

Executes end-to-end tests using Playwright or Cypress. Ensure the development server and Keycloak are running before executing E2E tests.

### Coverage Report

```bash
npm run test:cov
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
| 7    | Verify Pinia auth store                   | Devtools show correct user state, roles, and token               |
| 8    | Access a role-restricted route as an unauthorized user | Access denied message or redirect                    |
| 9    | Make an authenticated API call            | Request includes Authorization header; response is successful    |
| 10   | Click Logout                              | Session terminated; redirected to login page                     |
| 11   | Verify token refresh                      | Session persists beyond the initial access token lifetime        |

---

## Docker

### Multi-Stage Dockerfile

The included `Dockerfile` uses a multi-stage build:

1. **builder** -- installs dependencies and builds the Vite application.
2. **runner** -- serves the compiled static files via nginx.

### Build and Run

```bash
# Build the image
docker build -t vue-iam .

# Run the container
docker run -p 8080:80 vue-iam
```

### Docker Compose

```bash
docker compose up -d
```

---

## Scripts Reference

| Script              | Command                | Description                              |
|---------------------|------------------------|------------------------------------------|
| `dev`               | `npm run dev`          | Start Vite development server            |
| `build`             | `npm run build`        | Create optimized production build        |
| `preview`           | `npm run preview`      | Preview production build locally         |
| `lint`              | `npm run lint`         | Run ESLint                               |
| `test`              | `npm test`             | Run unit tests (Vitest)                  |
| `test:e2e`          | `npm run test:e2e`     | Run end-to-end tests                     |
| `test:cov`          | `npm run test:cov`     | Generate test coverage report            |

---

## Troubleshooting

| Problem                                  | Possible Cause                              | Solution                                                        |
|------------------------------------------|---------------------------------------------|-----------------------------------------------------------------|
| Redirect loop after login                | Redirect URI mismatch                        | Verify the redirect URI in Keycloak client settings             |
| "Invalid redirect_uri" on Keycloak       | URI not registered in the client             | Add `http://localhost:5173` to valid redirect URIs              |
| CORS errors on API calls                 | Keycloak Web Origins misconfigured           | Add the application origin to Keycloak client Web Origins       |
| Theme flashes on page load               | Theme resolved after Vue mounts              | Add an inline script in `index.html` to set the theme class     |
| i18n messages not loading                | Missing locale file                          | Verify the locale file exists in `src/i18n/locales/`            |
| "ECONNREFUSED" connecting to Keycloak    | Keycloak is not running                      | Start Keycloak and verify the Keycloak URL                      |
| Pinia store not reactive                 | Store used outside of setup context          | Use `storeToRefs()` or access the store inside `setup()`        |
| Vite HMR not working                     | Network or firewall issue                    | Check that the Vite WebSocket port is accessible                |
| Docker build fails at dependency install | Lock file out of sync with `package.json`    | Run `npm install` locally first, then rebuild                   |
