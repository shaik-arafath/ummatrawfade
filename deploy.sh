#!/bin/bash

# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y nginx mysql-server openjdk-17-jdk certbot python3-certbot-nginx

# Install MySQL if not already installed
sudo mysql_secure_installation

# Create database and user
sudo mysql -e "CREATE DATABASE IF NOT EXISTS rawfade;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'rawfade_user'@'localhost' IDENTIFIED BY 'Arafath143@';"
sudo mysql -e "GRANT ALL PRIVILEGES ON rawfade.* TO 'rawfade_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Configure NGINX
sudo cp nginx.conf /etc/nginx/sites-available/rawfadeclothing.com
sudo ln -s /etc/nginx/sites-available/rawfadeclothing.com /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Create web root directory
sudo mkdir -p /var/www/rawfadeclothing.com
sudo chown -R $USER:$USER /var/www/rawfadeclothing.com

# Copy frontend files
sudo cp -r * /var/www/rawfadeclothing.com/

# Set up SSL
sudo certbot --nginx -d rawfadeclothing.com -d www.rawfadeclothing.com

# Deploy Spring Boot application
cd spring_backend
./mvnw clean package -DskipTests
sudo mkdir -p /opt/rawfade
sudo cp target/spring_backend-0.0.1-SNAPSHOT.jar /opt/rawfade/app.jar
sudo cp .env /opt/rawfade/

# Create systemd service for Spring Boot app
sudo tee /etc/systemd/system/rawfade.service << EOF
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

[Install]
WantedBy=multi-user.target
EOF

# Start services
sudo systemctl daemon-reload
sudo systemctl enable rawfade
sudo systemctl start rawfade
sudo systemctl restart nginx

# Print status
echo "Deployment completed!"
echo "Please check the following:"
echo "1. Frontend: https://rawfadeclothing.com"
echo "2. Backend: https://rawfadeclothing.com/api"
echo "3. SSL Status: https://www.ssllabs.com/ssltest/analyze.html?d=rawfadeclothing.com"
