#!/bin/bash

# Manual deployment script for VPS
# Run this on your VPS after copying files

set -e

echo "Starting deployment..."

# Create network if not exists
docker network create web 2>/dev/null || true

# Stop existing containers
docker compose down || true

# Build and start
docker compose up -d --build

echo "Deployment complete. Check status:"
docker ps

echo "Traefik dashboard: http://89.116.20.32:8080"
echo "App should be at: https://rawfadeclothing.com"
