# UMAT Automated Deployment Guide

## Overview

This guide explains how to deploy the UMAT application using the automated deployment scripts.

## Prerequisites

- Windows or Linux system with network access to the target server
- SSH access credentials for the target server
- Target server must have:
  - Ubuntu Server 20.04 or newer
  - Java 17 installed
  - MySQL 8.0 configured with proper credentials
  - Nginx web server

## Automated Deployment Process

### One-Click Deployment (Windows)

1. Double-click on **one_click_deploy.bat**
2. Enter your server password when prompted
3. Wait for the process to complete (approximately 5-10 minutes)

The script will automatically:
- Build the Spring Boot backend application
- Copy files to the server (89.116.20.32)
- Deploy frontend static files
- Restart all services
- Verify deployment status

### Linux/Mac Deployment

Run the deployment script:
```bash
./deploy.sh
```

## What the Script Does

1. **Build Phase**: Compiles the Spring Boot application using Maven
2. **Transfer Phase**: Securely copies files to the server via SCP
3. **Deployment Phase**: 
   - Stops running services
   - Updates application files
   - Applies database migrations if needed
   - Restarts backend service
   - Reloads Nginx configuration
4. **Verification Phase**: Checks service status and reports success/failure

## Configuration

Environment-specific settings are stored in:
- `config/deployment.properties` - Server connection details
- `src/main/resources/application-prod.properties` - Production configuration

## Troubleshooting

Common issues and solutions:

**Deployment fails during file transfer:**
- Verify network connectivity to 89.116.20.32
- Check SSH credentials
- Ensure sufficient disk space on the server

**Application fails to start:**
- Check systemd logs: `journalctl -u umat-backend.service`
- Verify database connection settings
- Ensure Java 17 is properly installed

**Website not accessible:**
- Check Nginx status: `systemctl status nginx`
- Verify firewall rules allow HTTP/HTTPS traffic
- Check DNS configuration for domain pointing to 89.116.20.32

For assistance, please provide the error messages displayed during deployment.
# UMAT Deployment Guide

## Overview

This guide explains how to deploy the UMAT application in a production environment. There are two ways to deploy the application:

1. Using the automated deployment scripts
2. Manual deployment with systemd and Nginx

## Automated Deployment

For automated deployment, refer to [AUTOMATED_DEPLOYMENT.md](file:///C:/Users/arafa/umat/umat/AUTOMATED_DEPLOYMENT.md).

## Manual Deployment

### Prerequisites

- Ubuntu Server 20.04 or newer
- Java 17
- Maven 3.6+
- MySQL 8.0 (or compatible database)
- Nginx

### Step-by-step Deployment

#### 1. Backend Setup

```bash
# Navigate to the backend directory
cd /var/www/umat/spring_backend

# Create production configuration
# Copy the application-prod.properties to src/main/resources/

# Build the application
mvn clean package -DskipTests

# Setup systemd service
# Copy umat-backend.service to /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable umat-backend.service
sudo systemctl start umat-backend.service
```

#### 2. Frontend Setup

The frontend consists of static HTML, CSS, and JavaScript files that should be placed in:
```
/var/www/umat/frontend
```

#### 3. Nginx Configuration

```bash
# Copy nginx-improved.conf to /etc/nginx/sites-available/umat.conf
sudo ln -sf /etc/nginx/sites-available/umat.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### 4. Environment Variables

Update the systemd service file with proper values for:
- DB_USERNAME
- DB_PASSWORD
- JWT_SECRET

### Monitoring

Check service status:
```bash
sudo systemctl status umat-backend.service
sudo systemctl status nginx
```

View logs:
```bash
sudo journalctl -u umat-backend.service -f
sudo tail -f /var/log/nginx/umat_access.log
```

### Security Considerations

1. Always use environment variables for sensitive configuration
2. Set up SSL with Let's Encrypt
3. Regularly update system packages
4. Restrict access to the backend port (8081) using firewall rules
5. Use strong passwords for database accounts

### Troubleshooting

If the application fails to start:
1. Check systemd logs: `journalctl -u umat-backend.service`
2. Verify database connectivity
3. Ensure all environment variables are properly set
4. Check file permissions