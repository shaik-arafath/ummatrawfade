@echo off
title Rawfade Clothing - Simple Deployment
color 0A

echo ======================================================
echo      RAWFADE CLOTHING - SIMPLE DEPLOYMENT          
echo ======================================================
echo.
echo This will deploy your website using a simple approach.
echo.

REM Read server configuration
if not exist "server_config.txt" (
    echo ERROR: Server configuration file not found!
    pause
    exit /b 1
)

for /f "usebackq tokens=*" %%i in ("server_config.txt") do (
    set %%i
)

echo Server Information:
echo IP Address: %SERVER_IP%
echo Username: %SERVER_USER%
echo Domain: %DOMAIN_NAME%
echo.

echo Building backend application...
cd spring_backend
call mvnw clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Backend build failed!
    cd ..
    pause
    exit /b %ERRORLEVEL%
)
cd ..

echo.
echo Backend built successfully!

echo.
echo Deploying with simple approach...
echo Please enter your VPS root password when prompted:
echo.

REM Create a simple deployment script for the server
echo Creating deployment script...
echo #!/bin/bash > deploy_simple.sh
echo echo "=== Simple Deployment ===" >> deploy_simple.sh
echo apt update >> deploy_simple.sh
echo apt install -y nginx openjdk-17-jdk >> deploy_simple.sh
echo systemctl start nginx >> deploy_simple.sh
echo systemctl enable nginx >> deploy_simple.sh
echo mkdir -p /var/www/rawfadeclothing.com >> deploy_simple.sh
echo mkdir -p /opt/rawfade >> deploy_simple.sh
echo cp -r * /var/www/rawfadeclothing.com/ >> deploy_simple.sh
echo cp spring_backend/target/*.jar /opt/rawfade/app.jar >> deploy_simple.sh
echo rm -rf /var/www/rawfadeclothing.com/spring_backend >> deploy_simple.sh
echo rm /var/www/rawfadeclothing.com/simple_deploy.bat >> deploy_simple.sh
echo rm /var/www/rawfadeclothing.com/deploy_simple.sh >> deploy_simple.sh
echo cp /var/www/rawfadeclothing.com/nginx.conf /etc/nginx/sites-available/rawfadeclothing.com >> deploy_simple.sh
echo ln -sf /etc/nginx/sites-available/rawfadeclothing.com /etc/nginx/sites-enabled/ >> deploy_simple.sh
echo rm -f /etc/nginx/sites-enabled/default >> deploy_simple.sh
echo systemctl restart nginx >> deploy_simple.sh
echo echo "Simple deployment completed!" >> deploy_simple.sh

REM Copy files to server
echo Copying files to server...
scp -r . root@%SERVER_IP%:/root/umat_simple

REM Run deployment script on server
echo Running deployment on server...
ssh root@%SERVER_IP% << 'EOF'
cd /root/umat_simple
chmod +x deploy_simple.sh
./deploy_simple.sh
EOF

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ======================================================
    echo SIMPLE DEPLOYMENT COMPLETED!
    echo.
    echo Your website should be available at:
    echo http://%SERVER_IP%
    echo.
    echo To make it work with your domain:
    echo 1. Point your domain DNS to %SERVER_IP%
    echo 2. Access via http://%DOMAIN_NAME%
    echo.
    echo Note: This is a simple HTTP deployment without SSL.
    echo For SSL, you would need to run additional commands.
    echo ======================================================
) else (
    echo.
    echo ======================================================
    echo DEPLOYMENT FAILED!
    echo Please check your connection and password.
    echo ======================================================
)

echo.
pause