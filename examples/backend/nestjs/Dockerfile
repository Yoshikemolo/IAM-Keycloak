# ---------------------------------------------------------------------------
# Multi-stage Dockerfile for the IAM NestJS Example.
#
# Stage 1 (build)  - Installs dependencies and compiles TypeScript.
# Stage 2 (runtime)- Copies compiled output and production dependencies only.
# ---------------------------------------------------------------------------

# ===== Stage 1: Build =====
FROM node:22-alpine AS build

WORKDIR /app

COPY examples/backend/nestjs/package.json examples/backend/nestjs/package-lock.json* ./
RUN npm ci

COPY examples/backend/nestjs/tsconfig.json examples/backend/nestjs/tsconfig.build.json examples/backend/nestjs/nest-cli.json ./
COPY examples/backend/nestjs/src/ src/

RUN npm run build

# ===== Stage 2: Runtime =====
FROM node:22-alpine

WORKDIR /app

ENV NODE_ENV=production

COPY examples/backend/nestjs/package.json examples/backend/nestjs/package-lock.json* ./
RUN npm ci --omit=dev

# Copy compiled output
COPY --from=build /app/dist/ dist/

# Copy runtime assets (views, public, i18n)
COPY examples/backend/nestjs/views/ views/
COPY examples/backend/nestjs/public/ public/
COPY examples/backend/nestjs/i18n/ i18n/

# Copy shared assets (fonts + branding) into the public directory
# so NestJS can serve them at /fonts/ and /branding/
COPY assets/fonts/ public/fonts/
COPY assets/branding/ public/branding/

EXPOSE 3001

CMD ["node", "dist/main.js"]
