# ---------------------------------------------------------------------------
# Dockerfile for the IAM Next.js Example application.
#
# Multi-stage build:
#   Stage 1 (build)  - Installs dependencies and produces an optimized
#                       production bundle via Next.js.
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

# Copy dependency manifests first for better layer caching.
COPY package.json package-lock.json* ./

# Install dependencies deterministically.
RUN npm ci

# Copy the rest of the application source.
COPY . .

# Produce the production build output.
RUN npm run build

# ---- Stage 2: Runtime ----
FROM nginx:alpine-slim AS runtime

# Remove the default Nginx static assets.
RUN rm -rf /usr/share/nginx/html/*

# Copy the custom Nginx configuration.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built application from the build stage.
COPY --from=build /app/out /usr/share/nginx/html

# Create writable directories required by Nginx when running as non-root.
RUN mkdir -p /var/cache/nginx /var/run && \
    chown -R nginx:nginx /var/cache/nginx /var/run /usr/share/nginx/html

# Expose port 80 for HTTP traffic.
EXPOSE 80

# Run as the non-root nginx user.
USER nginx

# Healthcheck to verify the container is serving traffic.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
