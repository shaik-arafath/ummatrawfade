@echo off
echo Rawfade Clothing - Automated Deployment
echo ========================================

echo Building Spring Boot backend...
cd spring_backend
call mvnw clean package -DskipTests
cd ..

echo Running deployment...
bash auto_deploy.sh

echo Deployment completed!
pause