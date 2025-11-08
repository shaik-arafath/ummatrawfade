@echo off
title Rawfade Clothing - SSL Fix
color 0A

echo ======================================================
echo        RAWFADE CLOTHING - SSL FIX TOOL          
echo ======================================================
echo.
echo This tool will help fix the SSL certificate issue.
echo.

REM Check if required tools exist
where ssh >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: SSH is not installed or not in PATH!
    echo Please install Git for Windows which includes SSH.
    echo Download from: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

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

echo You will be connected to your server to fix SSL certificates.
echo When prompted, enter your password: Arafathshaik143@
echo.

echo Press any key to continue...
pause >nul
echo.

echo Connecting to server and fixing SSL certificates...
echo ======================================================

ssh root@%SERVER_IP% << EOF
echo "=== Fixing SSL Certificate ==="

# Check if we're in the right directory
if [ ! -d "/root/umat" ]; then
    echo "Project directory not found. Checking common locations..."
    if [ -d "/root/umat" ]; then
        cd /root/umat
        echo "Found project in /root/umat"
    else
        echo "Project directory not found. Please deploy first."
        exit 1
    fi
else
    cd /root/umat
fi

# Make sure Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing..."
    apt update
    apt install -y docker.io docker-compose
    systemctl start docker
    systemctl enable docker
fi

# Stop existing services
echo "Stopping existing services..."
docker-compose down 2>/dev/null || true

# Remove old certificates that might be causing issues
echo "Removing old certificates..."
rm -f /letsencrypt/acme.json 2>/dev/null || true

# Recreate network
echo "Creating Docker network..."
docker network create web 2>/dev/null || true

# Start services with fresh certificates
echo "Starting services with fresh certificates..."
docker-compose up -d

# Give Traefik time to start and request certificates
echo "Waiting for services to start..."
sleep 30

# Check if certificates were generated
if [ -f /letsencrypt/acme.json ]; then
    echo "SUCCESS: SSL certificates generated successfully"
    FILESIZE=$(stat -c%s /letsencrypt/acme.json)
    if [ $FILESIZE -gt 2 ]; then
        echo "Certificate file looks good (not empty)"
    else
        echo "WARNING: Certificate file is empty. This might indicate an issue."
    fi
else
    echo "WARNING: SSL certificate file not found"
    echo "This usually means DNS is not properly configured"
    echo "Please make sure you have A records pointing to %SERVER_IP%"
fi

echo "=== SSL Fix Process Completed ==="
echo "Try accessing https://%DOMAIN_NAME% in 5-10 minutes"
EOF

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ======================================================
    echo SSL FIX PROCESS COMPLETED!
    echo.
    echo Important steps to make SSL work:
    echo 1. Make sure your DNS A records point to %SERVER_IP%
    echo 2. Try accessing https://%DOMAIN_NAME% in 5-10 minutes
    echo.
    echo If you still see the warning:
    echo 1. Wait longer for DNS propagation (up to 1 hour)
    echo 2. Make sure port 80 is accessible on your server
    echo 3. Check with your domain registrar
    echo ======================================================
) else (
    echo.
    echo ======================================================
    echo CONNECTION FAILED!
    echo.
    echo Possible issues:
    echo 1. Incorrect password
    echo 2. Server is not running
    echo 3. Network connectivity issues
    echo 4. SSH is blocked on your network
    echo ======================================================
)

echo.
pause