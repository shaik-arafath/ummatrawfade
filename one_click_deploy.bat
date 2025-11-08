@echo off
title Rawfade Clothing - One Click Deployment
color 0A

echo ======================================================
echo        RAWFADE CLOTHING - ONE CLICK DEPLOY          
echo ======================================================
echo.
echo This will automatically deploy your website to:
echo https://rawfadeclothing.com
echo.

REM Check if required files exist
if not exist "spring_backend\pom.xml" (
    echo ERROR: Backend files not found!
    echo Make sure you're running this from the project root directory.
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

for /f "tokens=*" %%i in (server_config.txt) do (
    set %%i
)

echo Server Information:
echo IP Address: %SERVER_IP%
echo Username: %SERVER_USER%
echo Domain: %DOMAIN_NAME%
echo.

echo Deployment Steps:
echo 1. Building backend application...
echo 2. Copying files to server...
echo 3. Starting services on server...
echo.

echo Building backend application...
cd spring_backend
call mvnw clean package -DskipTests > build.log 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Backend build failed!
    echo Check build.log for details.
    cd ..
    pause
    exit /b %ERRORLEVEL%
)
cd ..

echo.
echo Backend built successfully!

echo.
echo Copying files to server (%SERVER_IP%)...
echo Please enter your VPS root password when prompted:
echo.

REM Using the existing deploy script
bash deploy_with_docker.sh

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ======================================================
    echo DEPLOYMENT COMPLETED SUCCESSFULLY!
    echo.
    echo Your website is now available at:
    echo - http://%SERVER_IP% (direct access)
    echo.
    echo NOTE: For https://%DOMAIN_NAME% to work, you need to:
    echo 1. Log in to your domain registrar
    echo 2. Create A records pointing to %SERVER_IP%
    echo.
    echo This is the ONLY manual step required.
    echo ======================================================
) else (
    echo.
    echo ======================================================
    echo DEPLOYMENT FAILED!
    echo Please check the error messages above.
    echo ======================================================
)

echo.
pause