# ---------------------------------------------------------------------------
# Multi-stage Dockerfile for the IAM ASP.NET Core Example.
#
# Build context is the repository root (set in docker-compose.yml) so that
# shared assets (fonts, branding) can be copied into the image.
#
# Stage 1 (build): Uses the .NET 9 SDK image to restore, build, and publish
#                   the application in Release mode.
# Stage 2 (runtime): Uses the .NET 9 ASP.NET runtime image for a lean
#                     production container.
#
# Usage:
#   docker compose up --build
# ---------------------------------------------------------------------------

# ---------- Stage 1: Build ----------
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy project file and restore dependencies first (layer caching)
COPY examples/backend/aspnet-core/IAMExample.csproj .
RUN dotnet restore

# Copy the application source
COPY examples/backend/aspnet-core/ .
RUN dotnet publish -c Release -o /app/publish

# ---------- Stage 2: Runtime ----------
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Copy published output
COPY --from=build /app/publish .

# Copy shared font and branding assets into wwwroot so they are served
# as static files at /fonts/* and /branding/* respectively.
# These paths are referenced by the CSS @font-face rules and header logos.
COPY assets/fonts ./wwwroot/fonts
COPY assets/branding ./wwwroot/branding

ENV ASPNETCORE_URLS=http://+:5000
EXPOSE 5000

ENTRYPOINT ["dotnet", "IAMExample.dll"]
