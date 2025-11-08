# Automated Deployment System

This document explains how to use the fully automated deployment system for your Java full-stack project.

## How It Works

1. Every time you push code to the `main` branch of your GitHub repository, GitHub Actions automatically:
   - Builds your React frontend
   - Copies the frontend build to your Spring Boot backend's static resources
   - Packages everything into a Docker image
   - Deploys to your VPS at 89.116.20.32
   - Restarts your services with zero downtime

2. Traefik automatically handles:
   - SSL certificate generation via Let's Encrypt
   - HTTPS redirection
   - Load balancing

## Files in This System

- [.github/workflows/deploy.yml](file:///c%3A/Users/arafa/umat/umat/.github/workflows/deploy.yml) - GitHub Actions workflow that handles the deployment
- [docker-compose.yml](file:///c%3A/Users/arafa/umat/umat/docker-compose.yml) - Defines services for your application and Traefik
- [CI_CD_SETUP.md](file:///c%3A/Users/arafa/umat/umat/CI_CD_SETUP.md) - Detailed setup instructions
- [Dockerfile](file:///c%3A/Users/arafa/umat/umat/Dockerfile) - Builds your application into a Docker image

## Quick Start

1. Follow the setup instructions in [CI_CD_SETUP.md](file:///c%3A/Users/arafa/umat/umat/CI_CD_SETUP.md)

2. Push any change to your `main` branch:
   ```bash
   git add .
   git commit -m "Deploy my changes"
   git push origin main
   ```

3. Watch the deployment progress in GitHub Actions:
   - Go to your repository
   - Click "Actions" tab
   - Select the running workflow

4. Your site will be live at https://rawfadeclothing.com within a few minutes

## Zero-Downtime Deployment

The system uses Docker Compose to ensure zero-downtime deployments:
- New containers are built while old ones are still running
- Traffic is switched to new containers once they're ready
- Old containers are removed after successful deployment

## SSL Certificate Handling

Traefik automatically:
- Requests SSL certificates from Let's Encrypt
- Renews certificates before they expire
- Handles HTTP to HTTPS redirection

Certificates are stored in a Docker volume and will persist between deployments.

## Monitoring Your Deployment

Check your deployment status:
```bash
# SSH into your VPS
ssh root@89.116.20.32

# Check running services
docker ps

# View application logs
docker-compose logs app

# View Traefik logs
docker-compose logs traefik
```

## Traefik Dashboard

Access the Traefik dashboard at: http://89.116.20.32:8080

This shows:
- Configured routers and services
- Current certificate status
- System health information

## Rollback to Previous Version

If you need to rollback:
```bash
# SSH into your VPS
ssh root@89.116.20.32

# Navigate to project directory
cd /root/rawfade

# Revert to previous commit (replace COMMIT_HASH with actual hash)
git reset --hard COMMIT_HASH

# Redeploy
docker-compose down
docker-compose up -d --build
```

## Troubleshooting Common Issues

### Deployment Fails in GitHub Actions
- Check that your SSH key is properly configured in GitHub Secrets
- Verify your VPS is accessible and SSH service is running

### Site Not Accessible
- Check that DNS records point to 89.116.20.32
- Ensure ports 80 and 443 are not blocked by firewall
- Check container logs with `docker-compose logs`

### SSL Certificate Issues
- Wait up to 5 minutes for initial certificate generation
- Check that DNS records are properly configured
- Verify that port 80 is accessible (required for Let's Encrypt challenge)

With this system, every time you push code to your main branch, your website at https://rawfadeclothing.com will automatically update with zero manual steps required.