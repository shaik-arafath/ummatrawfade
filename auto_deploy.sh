#!/bin/bash

# Enhanced auto deployment script for VPS
# This script securely deploys the application to the VPS

set -e  # Exit on any error

echo "=== Rawfade Clothing - Automated Deployment ==="

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "Installing sshpass..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y sshpass
    elif command -v yum &> /dev/null; then
        sudo yum install -y sshpass
    else
        echo "Please install sshpass manually"
        exit 1
    fi
fi

# Build the Spring Boot backend locally
echo "Building Spring Boot backend..."
cd spring_backend
./mvnw clean package -DskipTests
cd ..

# Create a temporary directory for deployment files
DEPLOY_DIR="/tmp/deploy_$(date +%s)"
mkdir -p "$DEPLOY_DIR"

# Copy necessary files to deployment directory
echo "Preparing deployment files..."
cp -r . "$DEPLOY_DIR/"
rm -rf "$DEPLOY_DIR/.git"

# Set secure permissions for sensitive files
chmod 600 "$DEPLOY_DIR/auto_deploy.sh"

# SCP all files to the server
echo "Copying files to server..."
sshpass -e scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r "$DEPLOY_DIR"/* root@89.116.20.32:/tmp/umat

# Clean up temporary directory
rm -rf "$DEPLOY_DIR"

# SSH to server and run the remote deploy script
echo "Running deployment on server..."
sshpass -e ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@89.116.20.32 'bash /tmp/umat/deploy_remote.sh'

echo "Deployment completed successfully!"