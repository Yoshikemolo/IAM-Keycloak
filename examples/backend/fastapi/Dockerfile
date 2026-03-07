# ---------------------------------------------------------------------------
# Dockerfile for the IAM FastAPI Example application.
#
# Multi-stage build:
#   Stage 1 (build)   - Installs Python dependencies into a virtual env.
#   Stage 2 (runtime) - Copies the virtual env and application source into
#                        a minimal python:3.12-slim image.
#
# Security considerations:
#   - Runs as a non-root user (appuser).
#   - Uses a virtual environment for clean dependency isolation.
#   - Healthcheck ensures the container is responsive.
# ---------------------------------------------------------------------------

# ---- Stage 1: Build ----
FROM python:3.12-slim AS build

WORKDIR /build

# Install dependencies into a virtual environment for portability.
RUN python -m venv /build/venv
ENV PATH="/build/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---- Stage 2: Runtime ----
FROM python:3.12-slim AS runtime

# Create a non-root user.
RUN groupadd --gid 1000 appuser && \
    useradd --uid 1000 --gid appuser --shell /bin/bash --create-home appuser

WORKDIR /app

# Copy the virtual environment from the build stage.
COPY --from=build /build/venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Copy application source.
COPY . .

# Ensure the appuser owns the application directory.
RUN chown -R appuser:appuser /app

# Expose the application port.
EXPOSE 8000

# Run as non-root.
USER appuser

# Healthcheck to verify the container is serving traffic.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/')" || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
