# CI/CD Setup Guide

This guide will help you set up automated deployment for your Java full-stack project to your VPS at 89.116.20.32.

## Prerequisites

1. A GitHub repository with your project code
2. A VPS with Docker and Docker Compose installed
3. A domain name (rawfadeclothing.com) with DNS properly configured

## Step 1: Prepare Your VPS

SSH into your VPS and run these commands:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create Docker network
docker network create web

# Create deployment directory
mkdir -p /root/rawfade
```

## Step 2: Set Up SSH Key Authentication

On your local machine, generate an SSH key pair if you don't have one:

```bash
ssh-keygen -t rsa -b 4096 -C "github-actions"
```

Copy the public key to your VPS:

```bash
ssh-copy-id root@89.116.20.32
```

## Step 3: Add SSH Key to GitHub Secrets

1. Go to your GitHub repository
2. Click on "Settings" tab
3. Click on "Secrets and variables" in the left sidebar
4. Click "Actions" 
5. Click "New repository secret"
6. Name it `SSH_PRIVATE_KEY`
7. Paste your private SSH key (contents of ~/.ssh/id_rsa or the file you generated)
8. Click "Add secret"

## Step 4: Configure DNS

Set up DNS records for your domain:
- An A record for `rawfadeclothing.com` pointing to `89.116.20.32`
- An A record for `www.rawfadeclothing.com` pointing to `89.116.20.32`

## Step 5: Test the Deployment

Make a small change to your code and push it to the main branch:

```bash
git add .
git commit -m "Test CI/CD deployment"
git push origin main
```

Go to your GitHub repository > Actions tab to monitor the deployment process.

## Access Your Application

Once deployed, your application will be available at:
- http://89.116.20.32 (direct IP)
- https://rawfadeclothing.com (domain with SSL)

Traefik dashboard will be available at:
- http://89.116.20.32:8080

## Troubleshooting

If you encounter issues:

1. Check the GitHub Actions logs in your repository's Actions tab
2. SSH into your VPS and check container status:
   ```bash
   docker ps
   docker-compose logs
   ```
3. Make sure your DNS records have propagated
4. Check that port 80 and 443 are not blocked by firewall

## Manual Deployment (if needed)

If you need to manually deploy:

```bash
# SSH into your VPS
ssh root@89.116.20.32

# Navigate to project directory
cd /root/rawfade

# Pull latest changes (if git is set up)
git pull origin main

# Rebuild and restart services
docker-compose down
docker-compose up -d --build
```

This setup will automatically deploy your application every time you push changes to the main branch of your repository.