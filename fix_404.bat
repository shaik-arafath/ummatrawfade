@echo off
title Rawfade Clothing - Fix 404 Error
color 0A

echo ======================================================
echo        RAWFADE CLOTHING - 404 ERROR FIX          
echo ======================================================
echo.
echo This tool will diagnose and fix the 404 Page Not Found error.
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

echo You will be connected to your server to diagnose and fix the 404 error.
echo When prompted, enter your password: Arafathshaik143@
echo.

echo Press any key to continue...
pause >nul
echo.

echo Connecting to server and checking website status...
echo ======================================================

ssh root@%SERVER_IP% << EOF
echo "=== Diagnosing 404 Error ==="

# Check if we're in the right directory
cd /root/umat 2>/dev/null || echo "Project directory not found in /root/umat"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "ERROR: Docker Compose is not installed"
    exit 1
fi

# Check running containers
echo "=== Checking running containers ==="
docker ps

# Check container logs
echo "=== Checking container logs ==="
docker-compose logs --tail=20

# Check if files exist in web directory
echo "=== Checking web files ==="
if [ -d "/var/www/rawfadeclothing.com" ]; then
    echo "Web directory exists:"
    ls -la /var/www/rawfadeclothing.com | head -10
else
    echo "Web directory does not exist"
fi

# Check if Docker containers are working
echo "=== Checking Docker setup ==="
if [ -f "docker-compose.yml" ]; then
    echo "docker-compose.yml found"
else
    echo "ERROR: docker-compose.yml not found"
fi

# Try to rebuild and restart services
echo "=== Rebuilding and restarting services ==="
docker-compose down 2>/dev/null || true
docker-compose up -d --build

echo "=== Waiting for services to start ==="
sleep 20

echo "=== Checking status after restart ==="
docker ps

echo "=== Fix process completed ==="
echo "Try accessing your website in a few minutes"
EOF

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ======================================================
    echo DIAGNOSIS AND FIX PROCESS COMPLETED!
    echo.
    echo Please try accessing your website again in 2-5 minutes:
    echo 1. http://%SERVER_IP% (direct IP access)
    echo 2. http://%DOMAIN_NAME% (if DNS is configured)
    echo 3. https://%DOMAIN_NAME% (if SSL is working)
    echo.
    echo If you still see 404 errors:
    echo 1. Wait a bit longer for services to start
    echo 2. Check that all files were copied correctly
    echo 3. Make sure the index.html file exists
    echo ======================================================
) else (
    echo.
    echo ======================================================
    echo PROCESS FAILED!
    echo.
    echo Possible issues:
    echo 1. Incorrect password
    echo 2. Server is not running
    echo 3. Network connectivity issues
    echo ======================================================
)

echo.
pause