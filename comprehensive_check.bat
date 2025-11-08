@echo off
title Rawfade Clothing - Comprehensive Server Check
color 0C

echo ======================================================
echo    RAWFADE CLOTHING - COMPREHENSIVE SERVER CHECK          
echo ======================================================
echo.
echo This tool will perform a comprehensive check of your server.
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

echo You will be connected to your server for a comprehensive check.
echo When prompted, enter your password: Arafathshaik143@
echo.

echo Press any key to continue...
pause >nul
echo.

echo Performing comprehensive server check...
echo ========================================

ssh root@%SERVER_IP% << 'EOF'
echo "=== Comprehensive Server Check ==="

echo "1. Checking system information..."
echo "----------------------------------"
uname -a
echo ""
free -h
echo ""
df -h
echo ""
uptime

echo "2. Checking Docker installation..."
echo "----------------------------------"
if command -v docker &> /dev/null; then
    echo "Docker is installed:"
    docker --version
    echo ""
    echo "Docker service status:"
    systemctl is-active docker
else
    echo "Docker is NOT installed"
fi

echo ""
echo "3. Checking Docker Compose installation..."
echo "------------------------------------------"
if command -v docker-compose &> /dev/null; then
    echo "Docker Compose is installed:"
    docker-compose --version
else
    echo "Docker Compose is NOT installed"
fi

echo ""
echo "4. Checking project files..."
echo "----------------------------"
if [ -d "/root/umat" ]; then
    echo "Project directory exists:"
    ls -la /root/umat
    echo ""
    cd /root/umat
    if [ -f "docker-compose.yml" ]; then
        echo "docker-compose.yml file exists"
        echo "Contents:"
        cat docker-compose.yml | head -20
    else
        echo "ERROR: docker-compose.yml not found"
    fi
else
    echo "ERROR: Project directory not found"
fi

echo ""
echo "5. Checking Docker containers..."
echo "--------------------------------"
docker ps -a

echo ""
echo "6. Checking Docker networks..."
echo "------------------------------"
docker network ls

echo ""
echo "7. Checking system logs..."
echo "--------------------------"
journalctl -u docker --no-pager | tail -10

echo ""
echo "8. Checking if required ports are available..."
echo "----------------------------------------------"
netstat -tlnp | grep :80
netstat -tlnp | grep :443

echo ""
echo "=== Comprehensive check completed ==="
echo ""
echo "If you see many errors above, we should try a fresh installation."

# Ask user if they want to try a fresh installation
echo ""
echo "Would you like to try a fresh installation? (y/n)"
read answer
if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    echo "Performing fresh installation..."
    
    # Stop all containers
    cd /root/umat 2>/dev/null || true
    docker-compose down 2>/dev/null || true
    
    # Remove all containers, networks, and images related to the project
    docker rm -f $(docker ps -aq) 2>/dev/null || true
    docker network rm web 2>/dev/null || true
    docker rmi $(docker images -q) 2>/dev/null || true
    
    # Clean Docker system
    docker system prune -af
    
    # Reinstall Docker if needed
    if ! command -v docker &> /dev/null; then
        echo "Reinstalling Docker..."
        apt update
        apt install -y docker.io
        systemctl start docker
        systemctl enable docker
    fi
    
    # Reinstall Docker Compose if needed
    if ! command -v docker-compose &> /dev/null; then
        echo "Reinstalling Docker Compose..."
        curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
    
    # Recreate project
    cd /root/umat
    docker network create web 2>/dev/null || true
    docker-compose up -d --build
    
    echo "Fresh installation completed. Please wait 2-3 minutes and try accessing your site."
fi
EOF

echo.
echo ======================================================
echo COMPREHENSIVE CHECK COMPLETED!
echo.
echo Please review the information above to identify the issue.
echo.
echo If you still have problems:
echo 1. Try running one_click_deploy.bat again for a fresh deployment
echo 2. Consider rebooting your VPS from your hosting control panel
echo 3. Make sure your VPS has at least 1GB RAM and 10GB disk space
echo ======================================================

echo.
pause