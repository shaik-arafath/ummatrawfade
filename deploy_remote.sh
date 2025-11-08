#!/bin/bash

# Enhanced remote deployment script for VPS
# This script is run on the VPS after files are copied

set -e  # Exit on any error

echo "=== Starting Remote Deployment ==="

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt install -y nginx mysql-server openjdk-17-jdk certbot python3-certbot-nginx

# Ensure MySQL service is running
sudo systemctl start mysql || true
sudo systemctl enable mysql || true

# Create database and user
echo "Setting up database..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS rawfade;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'rawfade_user'@'localhost' IDENTIFIED BY 'Arafath143@';"
sudo mysql -e "GRANT ALL PRIVILEGES ON rawfade.* TO 'rawfade_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Initialize database schema if file exists
if [ -f /tmp/umat/spring_backend/sql/init.sql ]; then
    echo "Initializing database schema..."
    sudo mysql rawfade < /tmp/umat/spring_backend/sql/init.sql
fi

# Configure NGINX
echo "Configuring NGINX..."
sudo cp /tmp/umat/nginx.conf /etc/nginx/sites-available/rawfadeclothing.com
sudo ln -sf /etc/nginx/sites-available/rawfadeclothing.com /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Create web root directory
echo "Setting up web directory..."
sudo mkdir -p /var/www/rawfadeclothing.com
sudo chown -R $USER:$USER /var/www/rawfadeclothing.com

# Copy frontend files
echo "Copying frontend files..."
sudo cp -r /tmp/umat/* /var/www/rawfadeclothing.com/
sudo rm -rf /var/www/rawfadeclothing.com/spring_backend
sudo rm -f /var/www/rawfadeclothing.com/deploy.sh
sudo rm -f /var/www/rawfadeclothing.com/deploy_remote.sh
sudo rm -f /var/www/rawfadeclothing.com/auto_deploy.sh

# Deploy Spring Boot application
echo "Deploying Spring Boot application..."
sudo mkdir -p /opt/rawfade
sudo cp /tmp/umat/spring_backend/target/*.jar /opt/rawfade/app.jar

# Copy environment file if it exists
if [ -f /tmp/umat/.env ]; then
    sudo cp /tmp/umat/.env /opt/rawfade/
fi

# Create systemd service for Spring Boot app
echo "Creating systemd service..."
sudo tee /etc/systemd/system/rawfade.service > /dev/null << EOF
[Unit]
Description=Rawfade E-commerce Backend
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/rawfade
EnvironmentFile=/opt/rawfade/.env
ExecStart=/usr/bin/java -jar /opt/rawfade/app.jar
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Start services
echo "Starting services..."
sudo systemctl daemon-reload
sudo systemctl enable rawfade
sudo systemctl restart rawfade
sudo systemctl restart nginx

# Setup SSL certificate with Let's Encrypt
echo "Setting up SSL certificate..."
# This will only work if DNS is properly configured
sudo certbot --nginx -d rawfadeclothing.com -d www.rawfadeclothing.com --non-interactive --agree-tos --email arafathshaik121@gmail.com 2>/dev/null || echo "SSL setup failed. Please ensure DNS records are properly configured."

# Clean up
sudo rm -rf /tmp/umat

# Print status
echo "=== Deployment completed successfully! ==="
echo "Please check the following:"
echo "1. Frontend: https://rawfadeclothing.com (if SSL setup succeeded) or http://89.116.20.32"
echo "2. Backend: https://rawfadeclothing.com/api (if SSL setup succeeded) or http://89.116.20.32/api"
echo ""
echo "If the site is only accessible via IP address, please ensure DNS A records are properly configured:"
echo "- A record for rawfadeclothing.com pointing to 89.116.20.32"
echo "- A record for www.rawfadeclothing.com pointing to 89.116.20.32"
echo ""
echo "To manually set up SSL after DNS is configured, run:"
echo "sudo certbot --nginx -d rawfadeclothing.com -d www.rawfadeclothing.com --email your-email@example.com --agree-tos"