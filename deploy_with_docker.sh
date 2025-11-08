#!/bin/bash

# Docker-based deployment script for VPS
# This script deploys the application using Docker and Docker Compose

set -e  # Exit on any error

echo "=== Rawfade Clothing - Docker Deployment ==="
echo "This script will deploy your website to https://rawfadeclothing.com"
echo ""

# Get password from environment variable or prompt
if [ -z "$VPS_PASSWORD" ]; then
    echo "Please enter your VPS root password:"
    read -s VPS_PASSWORD
    echo ""
fi

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

# Create a temporary directory for deployment files
DEPLOY_DIR="/tmp/deploy_$(date +%s)"
mkdir -p "$DEPLOY_DIR"

# Copy necessary files to deployment directory
echo "Preparing deployment files..."
cp -r . "$DEPLOY_DIR/"
rm -rf "$DEPLOY_DIR/.git"

# Set secure permissions for sensitive files
chmod 600 "$DEPLOY_DIR/auto_deploy.sh" 2>/dev/null || true

# SCP all files to the server
echo "Copying files to server (89.116.20.32)..."
sshpass -p "$VPS_PASSWORD" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r "$DEPLOY_DIR"/* root@89.116.20.32:/root/umat

# Clean up temporary directory
rm -rf "$DEPLOY_DIR"

# SSH to server and run Docker deployment
echo "Running Docker deployment on server..."
sshpass -p "$VPS_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@89.116.20.32 << 'ENDSSH'
    echo "=== Starting deployment on VPS ==="
    
    # Update package list
    apt update
    
    # Install Docker if not already installed
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        apt install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        apt update
        apt install -y docker-ce
        systemctl start docker
        systemctl enable docker
        usermod -aG docker $USER
    fi
    
    # Install Docker Compose if not already installed
    if ! command -v docker-compose &> /dev/null; then
        echo "Installing Docker Compose..."
        curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
    
    # Navigate to project directory
    cd /root/umat
    
    # Create network if not exists
    docker network create web 2>/dev/null || true
    
    # Stop existing containers
    docker-compose down 2>/dev/null || true
    
    # Build and start containers
    docker-compose up -d --build
    
    echo ""
    echo "=== Docker deployment completed! ==="
    echo "Check container status with: docker ps"
    echo "Traefik dashboard: http://89.116.20.32:8080"
    echo "Application should be accessible at: http://89.116.20.32"
    echo ""
    echo "If DNS is properly configured, it will be accessible at: https://rawfadeclothing.com"
    echo ""
    echo "To check logs: docker-compose logs"
ENDSSH

echo ""
echo "=== Deployment process finished ==="
echo "Your website should be accessible at http://89.116.20.32"
echo "If DNS is properly configured, it will be accessible at https://rawfadeclothing.com"
echo ""
echo "For troubleshooting, please check DEPLOYMENT_GUIDE.md"