@echo off
title Rawfade Clothing - Docker Deployment
color 0A

echo ======================================================
echo        Rawfade Clothing - Docker Deployment         
echo ======================================================
echo.
echo This script will deploy your website to:
echo https://rawfadeclothing.com
echo.
echo Prerequisites:
echo 1. Your VPS at 89.116.20.32
echo 2. DNS records properly configured
echo.

echo Press any key to continue deployment...
pause >nul
echo.

echo Building project...
echo ==================
cd spring_backend
call mvnw clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo Error building backend!
    pause
    exit /b %ERRORLEVEL%
)
cd ..

echo.
echo Deploying with Docker...
echo =======================
bash deploy_with_docker.sh

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ======================================================
    echo Deployment completed successfully!
    echo.
    echo Your website should now be accessible at:
    echo - http://89.116.20.32 (direct IP)
    echo - https://rawfadeclothing.com (if DNS is configured)
    echo.
    echo For troubleshooting, check DEPLOYMENT_GUIDE.md
    echo ======================================================
) else (
    echo.
    echo ======================================================
    echo Deployment failed! Please check the error messages above.
    echo ======================================================
)

pause