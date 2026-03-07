# Next.js 15 -- IAM-Keycloak Frontend Example

A full-stack web application built with Next.js 15 (App Router), integrated with Keycloak for identity and access management. The project features internationalization (i18n) via next-intl and a dark/light theme system driven by CSS custom properties and `prefers-color-scheme`.

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

| Requirement   | Version |
|---------------|---------|
| Node.js       | 22.x    |
| npm or pnpm   | latest  |
| Docker Engine  | 24+     |
| Docker Compose | 2.x     |
| Keycloak       | 26+     |

---

## Quick Start

1. **Start Keycloak**

   ```bash
   docker compose -f ../../infrastructure/docker-compose.yml up -d keycloak
   ```

2. **Configure the Keycloak realm**

   Import the provided realm configuration or manually create a realm, client, and roles. Ensure redirect URIs include `http://localhost:3000/*`.

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

   Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## Project Structure

```
nextjs/
├── app/                    # App Router pages and layouts
│   ├── [locale]/           # Locale-aware routes
│   ├── api/                # API route handlers
│   └── layout.tsx          # Root layout
├── auth/                   # NextAuth / Keycloak integration
├── components/             # Reusable UI components
├── i18n/                   # next-intl configuration and message files
├── styles/                 # Global CSS, theme custom properties
├── public/                 # Static assets
├── scripts/                # DevOps helper scripts
├── Dockerfile              # Multi-stage production build
├── docker-compose.yml      # Local orchestration
├── next.config.ts          # Next.js configuration
└── package.json
```

---

## Configuration

All configuration is managed through environment variables. Create a `.env.local` file in the project root.

| Variable                  | Description                                      | Default / Example                          |
|---------------------------|--------------------------------------------------|--------------------------------------------|
| `KEYCLOAK_ISSUER`         | Keycloak issuer URL                              | `http://localhost:8080/realms/my-realm`     |
| `KEYCLOAK_CLIENT_ID`      | OAuth 2.0 client identifier                      | `nextjs-app`                               |
| `KEYCLOAK_CLIENT_SECRET`  | OAuth 2.0 client secret                          | (provided by Keycloak)                     |
| `NEXTAUTH_URL`            | Canonical URL of the application                 | `http://localhost:3000`                     |
| `NEXTAUTH_SECRET`         | Secret used to encrypt session tokens            | (generate with `openssl rand -base64 32`)  |
| `NEXT_PUBLIC_DEFAULT_LOCALE` | Default locale for i18n                       | `en`                                       |

---

## Running the Application

```bash
# Development (with hot reload)
npm run dev

# Production build
npm run build
npm start
```

---

## Features

### Internationalization (i18n)

Powered by **next-intl**. Message files reside in `i18n/messages/`. Supported locales are configured in `i18n/config.ts`. The active locale is resolved from the URL path segment (`/en/...`, `/lt/...`, etc.).

### Dark / Light Theme

The theme system uses CSS custom properties defined in `styles/`. The default theme follows the user's operating system preference via `prefers-color-scheme`. A manual toggle allows users to override the system setting; the choice is persisted in `localStorage`.

### Role-Based Rendering

Components inspect the authenticated user's Keycloak roles to conditionally render UI elements. Server-side route protection ensures unauthorized users cannot access restricted pages.

---

## Testing

### Unit Tests

```bash
npm test
```

Runs the unit test suite using Jest or Vitest with React Testing Library.

### End-to-End Tests

```bash
npm run test:e2e
```

Executes end-to-end tests using Playwright (or Cypress). Ensure the development server and Keycloak are running before executing E2E tests.

### Coverage Report

```bash
npm run test:cov
```

Generates a coverage report in the `coverage/` directory.

---

## Verification Checklist

Use the following checklist to manually verify core functionality after deployment or significant changes.

| Step | Action                                    | Expected Result                                                  |
|------|-------------------------------------------|------------------------------------------------------------------|
| 1    | Open the application root URL             | Redirected to Keycloak login page                                |
| 2    | Log in with valid credentials             | Redirected back to the application; user name displayed          |
| 3    | Check role display                        | Assigned Keycloak roles appear in the user profile section       |
| 4    | Switch language                           | UI labels, headings, and messages update to the selected locale  |
| 5    | Toggle theme                              | Application switches between dark and light themes               |
| 6    | Verify system theme preference            | On first visit, theme matches OS preference                      |
| 7    | Access a protected API route              | Authenticated request succeeds; unauthenticated request returns 401 |
| 8    | Access a role-restricted page as an unauthorized user | Access denied message or redirect                    |
| 9    | Click Logout                              | Session terminated; redirected to login page                     |
| 10   | Verify token refresh                      | Session persists beyond the initial access token lifetime        |

---

## Docker

### Multi-Stage Dockerfile

The included `Dockerfile` uses a multi-stage build:

1. **deps** -- installs production dependencies.
2. **builder** -- builds the Next.js application.
3. **runner** -- serves the application with a minimal Node.js image (or nginx for static export).

### Build and Run

```bash
# Build the image
docker build -t nextjs-iam .

# Run the container
docker run -p 3000:3000 --env-file .env.local nextjs-iam
```

### Docker Compose

```bash
docker compose up -d
```

The `docker-compose.yml` file orchestrates the Next.js application alongside Keycloak and any required backing services.

---

## Scripts Reference

| Script              | Command                | Description                              |
|---------------------|------------------------|------------------------------------------|
| `dev`               | `npm run dev`          | Start development server with hot reload |
| `build`             | `npm run build`        | Create optimized production build        |
| `start`             | `npm start`            | Start production server                  |
| `lint`              | `npm run lint`         | Run ESLint                               |
| `test`              | `npm test`             | Run unit tests                           |
| `test:e2e`          | `npm run test:e2e`     | Run end-to-end tests                     |
| `test:cov`          | `npm run test:cov`     | Generate test coverage report            |
| `analyze`           | `npm run analyze`      | Analyze production bundle size           |

---

## Troubleshooting

| Problem                                  | Possible Cause                              | Solution                                                        |
|------------------------------------------|---------------------------------------------|-----------------------------------------------------------------|
| Redirect loop after login                | `NEXTAUTH_URL` does not match the actual URL | Set `NEXTAUTH_URL` to the exact URL used in the browser         |
| "Invalid redirect_uri" on Keycloak       | Redirect URI not registered in the client    | Add the application URL to the client's valid redirect URIs     |
| CORS errors on API calls                 | Keycloak Web Origins misconfigured           | Add the application origin to the Keycloak client Web Origins   |
| Theme flashes on page load               | SSR does not know the user's preference      | Ensure the theme script runs before first paint (inline script) |
| i18n messages not loading                | Missing message file for the locale          | Verify the locale file exists in `i18n/messages/`               |
| "ECONNREFUSED" connecting to Keycloak    | Keycloak is not running or unreachable       | Start Keycloak and verify the `KEYCLOAK_ISSUER` URL             |
| Docker build fails at dependency install | Lock file out of sync with `package.json`    | Run `npm install` locally first, then rebuild                   |
| 401 on protected API routes              | Expired or missing access token              | Check token refresh configuration; verify session is active     |
