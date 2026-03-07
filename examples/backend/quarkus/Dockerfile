# ---------------------------------------------------------------------------
# Multi-stage Dockerfile for the IAM Quarkus Example.
#
# Stage 1 (build): Uses eclipse-temurin:17-jdk-alpine to compile the
#                   application with Maven.
# Stage 2 (runtime): Uses eclipse-temurin:17-jre-alpine for the smallest
#                     possible runtime image.
# ---------------------------------------------------------------------------

# ===== Stage 1: Build =====
FROM eclipse-temurin:17-jdk-alpine AS build

WORKDIR /app

# Install Maven (Alpine does not include it by default)
RUN apk add --no-cache maven

# Copy POM first for layer caching
COPY pom.xml ./
RUN mvn dependency:resolve -B

# Copy source and build
COPY src ./src
RUN mvn package -DskipTests -B

# ===== Stage 2: Runtime =====
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy the Quarkus fast-jar output from the build stage
COPY --from=build /app/target/quarkus-app/ ./quarkus-app/

EXPOSE 8082

ENTRYPOINT ["java", "-jar", "quarkus-app/quarkus-run.jar"]
