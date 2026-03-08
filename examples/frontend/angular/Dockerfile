# ---------------------------------------------------------------------------
# Dockerfile for the IAM Angular Example application.
#
# Multi-stage build:
#   Stage 1 (build)  - Installs dependencies and produces an optimized
#                       production bundle via Angular CLI.
#   Stage 2 (runtime) - Serves the static assets through Nginx with a
#                       minimal Alpine-based image.
#
# Security considerations:
#   - Runs as a non-root user (nginx).
#   - Uses read-only root filesystem where possible.
#   - Healthcheck ensures the container is responsive.
# ---------------------------------------------------------------------------

# ---- Stage 1: Build ----
FROM node:22-alpine AS build

WORKDIR /app

# Build configuration: "development" for local Docker, "production" for deploy.
ARG NG_CONFIG=development

# Copy dependency manifests first for better layer caching.
COPY package.json package-lock.json* ./

# Install dependencies deterministically.
RUN npm ci

# Copy the rest of the application source.
COPY . .

# Produce the build output in /app/dist using the selected configuration.
RUN npx ng build --configuration=${NG_CONFIG}

# ---- Stage 2: Runtime ----
FROM nginx:alpine-slim AS runtime

# Remove the default Nginx static assets.
RUN rm -rf /usr/share/nginx/html/*

# Copy the custom Nginx configuration.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built application from the build stage.
COPY --from=build /app/dist/iam-angular-example/browser /usr/share/nginx/html

# Configure Nginx to run as non-root: write the PID file to /tmp and ensure
# writable directories for cache and logs.
RUN sed -i 's|/run/nginx.pid|/tmp/nginx.pid|' /etc/nginx/nginx.conf && \
    mkdir -p /var/cache/nginx /tmp && \
    chown -R nginx:nginx /var/cache/nginx /tmp /usr/share/nginx/html

# Expose port 80 for HTTP traffic.
EXPOSE 80

# Run as the non-root nginx user.
USER nginx

# Healthcheck to verify the container is serving traffic.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
