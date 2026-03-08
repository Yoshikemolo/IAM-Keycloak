# ---------------------------------------------------------------------------
# Multi-stage Dockerfile for the IAM Express.js Example.
#
# Stage 1 (build)  - Installs dependencies and compiles TypeScript.
# Stage 2 (runtime)- Copies compiled output and production dependencies only.
# ---------------------------------------------------------------------------

# ===== Stage 1: Build =====
FROM node:22-alpine AS build

WORKDIR /app

COPY examples/backend/express/package.json examples/backend/express/package-lock.json* ./
RUN npm ci

COPY examples/backend/express/tsconfig.json ./
COPY examples/backend/express/src/ src/

RUN npm run build

# ===== Stage 2: Runtime =====
FROM node:22-alpine

WORKDIR /app

ENV NODE_ENV=production

COPY examples/backend/express/package.json examples/backend/express/package-lock.json* ./
RUN npm ci --omit=dev

# Copy compiled output
COPY --from=build /app/dist/ dist/

# Copy runtime assets (views, public, i18n, shared fonts/branding)
COPY examples/backend/express/views/ views/
COPY examples/backend/express/public/ public/
COPY examples/backend/express/i18n/ i18n/

# Copy shared assets (fonts + branding) into the public directory
# so Express can serve them at /fonts/ and /branding/
COPY assets/fonts/ public/fonts/
COPY assets/branding/ public/branding/

EXPOSE 3000

CMD ["node", "dist/server.js"]
