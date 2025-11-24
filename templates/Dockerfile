# ============================================
# DOCKERFILE FOR SPRING BOOT BACKEND
# ============================================
# This Dockerfile builds and runs your Spring Boot application
# It uses a multi-stage build for optimization
#
# USAGE:
# - Place this file in your backend/ directory
# - Render will automatically detect and use it
# - No changes needed unless you have custom requirements
#
# BUILD LOCALLY (optional):
#   docker build -t your-app-backend .
#   docker run -p 8080:8080 your-app-backend
# ============================================

# ============================================
# Stage 1: Build the application
# ============================================
FROM maven:3.8.7-openjdk-21 AS build

# Set working directory
WORKDIR /app

# Copy Maven configuration
COPY pom.xml .

# Download dependencies (cached layer)
# RUN mvn dependency:go-offline  # Uncomment for faster builds

# Copy source code
COPY src ./src

# Build the application
# -DskipTests: Skip tests during build (run separately in CI/CD)
# -Dmaven.test.skip=true: Alternative if above doesn't work
RUN mvn clean package -DskipTests

# ============================================
# Stage 2: Run the application
# ============================================
FROM openjdk:21-jdk-slim

# Set working directory
WORKDIR /app

# Copy the built JAR from build stage
# IMPORTANT: Update the JAR filename to match your pom.xml configuration
# Format: [artifactId]-[version].jar
# Example: myapp-1.0.0-SNAPSHOT.jar
COPY --from=build /app/target/*.jar app.jar

# Expose port (must match Spring Boot server.port)
EXPOSE 8080

# Health check (optional but recommended for Render)
# Adjust the endpoint to match your actuator configuration
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
# Java options:
# -Xmx: Maximum heap size (adjust based on your Render plan)
# -Xms: Initial heap size
# -XX:+UseG1GC: Use G1 garbage collector (good for Spring Boot)
# -Dspring.profiles.active: Activate Spring profile (set via ENV var instead)
ENTRYPOINT ["java", \
  "-Xmx512m", \
  "-Xms256m", \
  "-XX:+UseG1GC", \
  "-jar", \
  "app.jar"]

# ============================================
# RENDER CONFIGURATION
# ============================================
# In Render Dashboard:
# 1. Language: Docker ✓
# 2. Build Command: (leave empty - Docker handles it)
# 3. Start Command: (leave empty - Docker handles it)
# 4. Environment Variables: Add all from RENDER_ENV_VARS_TEMPLATE.txt
# ============================================

# ============================================
# MEMORY CONFIGURATION BY RENDER PLAN
# ============================================
# Adjust -Xmx and -Xms based on your Render plan:
#
# Free Tier (512 MB RAM):
#   -Xmx256m -Xms128m
#
# Starter ($7/mo, 512 MB RAM):
#   -Xmx384m -Xms192m
#
# Standard ($25/mo, 2 GB RAM):
#   -Xmx1536m -Xms768m
#
# Pro ($85/mo, 4 GB RAM):
#   -Xmx3072m -Xms1536m
#
# Leave ~25% RAM for OS and other processes
# ============================================

# ============================================
# TROUBLESHOOTING
# ============================================
# Build fails "No such file or directory"?
# - Ensure pom.xml is in backend/ directory
# - Verify mvnw files are committed (not in .gitignore)
#
# "Cannot find module" errors?
# - Clear Maven cache: docker build --no-cache
# - Check pom.xml dependencies are correct
#
# Application won't start?
# - Check logs for OutOfMemoryError → reduce -Xmx
# - Verify environment variables are set in Render
# - Check application.yml for required properties
#
# Health check failing?
# - Ensure Spring Boot Actuator is enabled
# - Verify endpoint path in HEALTHCHECK command
# - Check server.port matches EXPOSE directive
# ============================================

# ============================================
# CUSTOMIZATION
# ============================================
# Different Java version?
# - Change: openjdk:21-jdk-slim → openjdk:17-jdk-slim
# - Update: maven:3.8.7-openjdk-21 → maven:3.8.7-openjdk-17
#
# Need additional tools?
# - Add: RUN apt-get update && apt-get install -y <package>
# - Place after FROM openjdk line
#
# Custom JAR name?
# - Update: COPY --from=build /app/target/your-custom-name.jar app.jar
# ============================================

