# ---------------------------------------------------------------------------
# Multi-stage Dockerfile for the IAM Spring Boot Example.
#
# Stage 1 (build): Uses eclipse-temurin:17-jdk-alpine to compile the
#                   application with Maven.
# Stage 2 (runtime): Uses eclipse-temurin:17-jre-alpine for the smallest
#                     possible runtime image.
# ---------------------------------------------------------------------------

# ===== Stage 1: Build =====
FROM eclipse-temurin:17-jdk-alpine AS build

WORKDIR /app

# Copy Maven wrapper and POM first for layer caching
COPY pom.xml ./
COPY .mvn .mvn
COPY mvnw ./
RUN chmod +x mvnw && ./mvnw dependency:resolve -B

# Copy source and build the JAR
COPY src ./src
RUN ./mvnw package -DskipTests -B

# ===== Stage 2: Runtime =====
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy the built JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]
