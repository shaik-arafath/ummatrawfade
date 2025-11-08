# Multi-stage build: Frontend
FROM node:18 AS frontend

WORKDIR /app

# Copy frontend files
COPY frontend/package*.json ./ 2>/dev/null || true
RUN npm install 2>/dev/null || true

COPY frontend/ ./frontend/
RUN npm run build 2>/dev/null || true

# Backend stage
FROM eclipse-temurin:17-jdk AS backend

WORKDIR /app

# Install Maven
RUN apt-get update && apt-get install -y maven

# Copy frontend build to static resources
COPY --from=frontend /app/frontend/build /app/src/main/resources/static 2>/dev/null || true

# Copy backend source
COPY backend/pom.xml .
COPY backend/src ./src

# Build backend
RUN mvn clean package -DskipTests

EXPOSE 8080

CMD ["java", "-jar", "target/*.jar"]