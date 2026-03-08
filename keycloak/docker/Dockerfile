###############################################################################
# Dockerfile -- Lightweight Keycloak image for local development
#
# This Dockerfile builds a development-ready Keycloak 26.4.2 image with
# custom themes, realm configurations, and pre-built provider JARs.
# Unlike the production multi-stage build (infra/docker/Dockerfile.keycloak),
# this image skips Maven compilation and expects pre-built JARs.
#
# Build (from the repository root):
#   docker build -f keycloak/docker/Dockerfile -t iam-keycloak-dev:latest .
#
# Run:
#   docker run -p 8080:8080 -p 9000:9000 \
#       -e KEYCLOAK_ADMIN=admin \
#       -e KEYCLOAK_ADMIN_PASSWORD=admin \
#       iam-keycloak-dev:latest
###############################################################################

FROM quay.io/keycloak/keycloak:26.4.2

# -- OCI labels ---------------------------------------------------------------
LABEL org.opencontainers.image.title="X-IAM Keycloak (dev)"
LABEL org.opencontainers.image.description="Development Keycloak with custom themes and realm import"
LABEL org.opencontainers.image.vendor="Ximplicity Software Solutions S.L."

# -- Environment defaults for development ------------------------------------
ENV KC_DB=postgres \
    KC_DB_URL=jdbc:postgresql://postgres:5432/keycloak \
    KC_DB_USERNAME=keycloak \
    KC_DB_PASSWORD=changeme \
    KC_HEALTH_ENABLED=true \
    KC_METRICS_ENABLED=true \
    KC_FEATURES=token-exchange,admin-fine-grained-authz,declarative-user-profile \
    KC_HTTP_RELATIVE_PATH=/ \
    KC_HOSTNAME_STRICT=false \
    KC_LOG_LEVEL=debug \
    KEYCLOAK_ADMIN=admin \
    KEYCLOAK_ADMIN_PASSWORD=admin

# -- Copy themes and realm configuration -------------------------------------
COPY keycloak/themes/ /opt/keycloak/themes/
COPY keycloak/realms/ /opt/keycloak/data/import/
COPY keycloak/config/ /opt/keycloak/conf/

# -- Expose ports -------------------------------------------------------------
EXPOSE 8080 9000

# -- Health check -------------------------------------------------------------
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD exec curl --fail --silent http://localhost:9000/health/ready || exit 1

# -- Start in development mode with realm import ------------------------------
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start-dev", "--import-realm"]
