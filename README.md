# Rawfade Clothing - Automated Deployment

This repository contains a Java full-stack e-commerce application with automated deployment to https://rawfadeclothing.com.

## Technology Stack

- **Frontend**: React (Node 18)
- **Backend**: Spring Boot (Java 17)
- **Deployment**: Docker + GitHub Actions + Coolify/Traefik
- **VPS**: Ubuntu Server at 89.116.20.32

## Automated Deployment

Every push to the `main` branch triggers an automated deployment via GitHub Actions:

1. Builds React frontend
2. Packages frontend with Spring Boot backend
3. Deploys to VPS via SSH
4. Coolify manages the service with automatic SSL

## Key Files

- [Dockerfile](file:///c%3A/Users/arafa/umat/umat/Dockerfile) - Multi-stage build for frontend and backend
- [docker-compose.yml](file:///c%3A/Users/arafa/umat/umat/docker-compose.yml) - Service definition for Coolify
- [.github/workflows/deploy.yml](file:///c%3A/Users/arafa/umat/umat/.github/workflows/deploy.yml) - GitHub Actions deployment workflow
- [DEPLOYMENT_GUIDE.md](file:///c%3A/Users/arafa/umat/umat/DEPLOYMENT_GUIDE.md) - Complete setup instructions

## Setup Instructions

See [DEPLOYMENT_GUIDE.md](file:///c%3A/Users/arafa/umat/umat/DEPLOYMENT_GUIDE.md) for complete setup instructions.

## Development

To run locally:

```bash
# Start backend
cd backend
./mvnw spring-boot:run

# In another terminal, start frontend
cd frontend
npm install
npm start
```

## Deployment

Simply push to the main branch:

```bash
git add .
git commit -m "Update application"
git push origin main
```

The deployment will happen automatically through GitHub Actions and Coolify.

## Access Points

- Production: https://rawfadeclothing.com
- Direct IP: http://89.116.20.32:8080