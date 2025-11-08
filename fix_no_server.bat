@echo off
title Rawfade Clothing - Fix No Server Error
color 0A

echo ======================================================
echo      RAWFADE CLOTHING - NO SERVER ERROR FIX          
echo ======================================================
echo.
echo This tool will diagnose and fix the "No Available Server" error.
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

echo You will be connected to your server to diagnose and fix the server error.
echo When prompted, enter your password: Arafathshaik143@
echo.

echo Press any key to continue...
pause >nul
echo.

echo Connecting to server and checking server status...
echo ======================================================

ssh root@%SERVER_IP% << 'EOF'
echo "=== Diagnosing No Available Server Error ==="

# Check system resources
echo "=== Checking system resources ==="
free -h
df -h

# Check if Docker is installed and running
echo "=== Checking Docker service ==="
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    apt update
    apt install -y docker.io
fi

systemctl status docker >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Starting Docker service..."
    systemctl start docker
    systemctl enable docker
else
    echo "Docker service is running"
fi

# Check if Docker Compose is installed
echo "=== Checking Docker Compose ==="
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose is installed"
fi

# Check project directory
echo "=== Checking project directory ==="
if [ ! -d "/root/umat" ]; then
    echo "ERROR: Project directory not found!"
    echo "You need to deploy the project first using one_click_deploy.bat"
    exit 1
else
    echo "Project directory found"
    cd /root/umat
fi

# Check docker-compose.yml file
echo "=== Checking docker-compose file ==="
if [ ! -f "docker-compose.yml" ]; then
    echo "ERROR: docker-compose.yml not found!"
    exit 1
else
    echo "docker-compose.yml found"
fi

# Check Docker network
echo "=== Checking Docker network ==="
docker network ls | grep web >/dev/null
if [ $? -ne 0 ]; then
    echo "Creating web network..."
    docker network create web
else
    echo "Web network exists"
fi

# Stop any existing services
echo "=== Stopping existing services ==="
docker-compose down 2>/dev/null || true

# Remove any problematic containers
echo "=== Cleaning up old containers ==="
docker rm -f $(docker ps -aq) 2>/dev/null || true

# Build and start services
echo "=== Building and starting services ==="
docker-compose up -d --build

# Wait for services to start
echo "=== Waiting for services to start ==="
sleep 30

# Check running containers
echo "=== Checking running containers ==="
docker ps

# Check container logs
echo "=== Checking container logs ==="
docker-compose logs --tail=30

echo "=== Server fix process completed ==="
echo "Try accessing your website in a few minutes"
EOF

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ======================================================
    echo SERVER FIX PROCESS COMPLETED!
    echo.
    echo Please try accessing your website again in 3-5 minutes:
    echo 1. http://%SERVER_IP% (direct IP access)
    echo 2. http://%DOMAIN_NAME% (if DNS is configured)
    echo 3. https://%DOMAIN_NAME% (if SSL is working)
    echo.
    echo If you still see "No Available Server" errors:
    echo 1. Wait a bit longer for services to start
    echo 2. Run one_click_deploy.bat to do a full redeploy
    echo 3. Check that your server has enough resources (RAM, disk space)
    echo ======================================================
) else (
    echo.
    echo ======================================================
    echo PROCESS FAILED!
    echo.
    echo Possible issues:
    echo 1. Incorrect password
    echo 2. Server is not running or is overloaded
    echo 3. Network connectivity issues
    echo 4. Server doesn't have enough resources
    echo ======================================================
)

echo.
pause