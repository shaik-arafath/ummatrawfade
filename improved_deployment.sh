#!/bin/bash

# Improved deployment script for UMAT application

set -e  # Exit on any error

echo "Starting UMAT deployment..."

# 1. Go to backend directory
echo "1. Changing to backend directory..."
cd /var/www/umat/spring_backend || { echo "Failed to change directory"; exit 1; }

# 2. Update application.properties with proper configuration management
echo "2. Configuring application..."
cat > src/main/resources/application-prod.properties <<'EOF'
# Production configuration
server.port=8081

# Database configuration (adjust as needed for your production DB)
spring.datasource.url=jdbc:mysql://localhost:3306/umat_prod?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.jpa.database-platform=org.hibernate.dialect.MySQLDialect

# JWT Secret (should be set via environment variable in production)
jwt.secret=${JWT_SECRET}

# Logging
logging.level.com.umat.backend=INFO
EOF

# 3. Rebuild the backend
echo "3. Building the backend application..."
mvn clean package -DskipTests -Pprod

# 4. Create a systemd service file for better process management
echo "4. Creating systemd service..."
cat > /etc/systemd/system/umat-backend.service <<'EOF'
[Unit]
Description=UMAT Backend Application
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/umat/spring_backend
ExecStart=/usr/bin/java -jar target/spring_backend-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod
Environment=SPRING_PROFILES_ACTIVE=prod
Environment=DB_USERNAME=your_db_username
Environment=DB_PASSWORD=your_db_password
Environment=JWT_SECRET=your_jwt_secret_key_change_in_production

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 5. Start the backend service
echo "5. Starting backend service..."
systemctl daemon-reload
systemctl enable umat-backend.service
systemctl restart umat-backend.service

# 6. Wait for backend to start
echo "6. Waiting for backend to start..."
sleep 10

# 7. Verify backend started
echo "7. Checking if backend is running..."
if systemctl is-active --quiet umat-backend.service; then
    echo "Backend service is running"
else
    echo "ERROR: Backend service failed to start"
    systemctl status umat-backend.service
    exit 1
fi

# 8. Install Nginx (if not installed)
echo "8. Installing and configuring Nginx..."
apt update -y && apt install nginx -y

# 9. Create improved Nginx configuration with security enhancements
echo "9. Creating Nginx configuration..."
cat > /etc/nginx/sites-available/umat.conf <<'EOF'
server {
    listen 80;
    server_name your_domain.com www.your_domain.com;  # Change to your domain
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline';" always;
    
    # Rate limiting for API endpoints
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    
    # Proxy backend requests with better configuration
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://localhost:8081/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 90;
    }

    # Serve static frontend files
    location / {
        root /var/www/umat/frontend;
        index index.html;
        try_files $uri $uri/ /index.html;
        
        # Caching headers for static assets
        location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # Deny access to sensitive files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
    
    # Log files
    access_log /var/log/nginx/umat_access.log;
    error_log /var/log/nginx/umat_error.log;
}

# Redirect www to non-www (optional)
server {
    listen 80;
    server_name www.your_domain.com;
    return 301 http://your_domain.com$request_uri;
}
EOF

# 10. Enable site and restart Nginx
echo "10. Enabling site and restarting Nginx..."
ln -sf /etc/nginx/sites-available/umat.conf /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx

# 11. Final verification
echo "11. Final verification..."
if systemctl is-active --quiet nginx; then
    echo "Nginx is running"
else
    echo "ERROR: Nginx failed to start"
    systemctl status nginx
    exit 1
fi

echo "Deployment completed successfully!"
echo "Remember to:"
echo "1. Update the domain name in the Nginx configuration"
echo "2. Set proper database credentials in the systemd service file"
echo "3. Configure SSL certificate (consider using Let's Encrypt)"
echo "4. Set a strong JWT secret"