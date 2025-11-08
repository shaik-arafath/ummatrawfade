# Automated Deployment Guide

This guide explains how to set up automated deployment for your Java full-stack project using GitHub Actions and Coolify.

## Files in This Setup

1. **[Dockerfile](file:///c%3A/Users/arafa/umat/umat/Dockerfile)** - Builds your React frontend and Spring Boot backend into a single Docker image
2. **[docker-compose.yml](file:///c%3A/Users/arafa/umat/umat/docker-compose.yml)** - Defines your application service for Coolify to manage
3. **[.github/workflows/deploy.yml](file:///c%3A/Users/arafa/umat/umat/.github/workflows/deploy.yml)** - GitHub Actions workflow that automatically deploys your app

## Prerequisites

1. A GitHub repository with your project code
2. A VPS at 89.116.20.32 with Docker, Docker Compose, and Coolify already installed
3. Your domain (rawfadeclothing.com) pointed to your VPS IP

## Setup Instructions

### Step 1: Generate SSH Key Pair

On your local machine, generate an SSH key pair if you don't have one:

```bash
# Check if you already have SSH keys
ls -la ~/.ssh/

# If no keys exist, generate a new SSH key pair
ssh-keygen -t rsa -b 4096 -C "github-actions" -f ~/.ssh/github-actions -N ""

# This creates:
# ~/.ssh/github-actions (private key)
# ~/.ssh/github-actions.pub (public key)
```

### Step 2: Add Public Key to VPS

Copy your public key to the VPS:

```bash
# Copy public key to VPS
ssh-copy-id -i ~/.ssh/github-actions.pub root@89.116.20.32

# Or manually add it:
# cat ~/.ssh/github-actions.pub | ssh root@89.116.20.32 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### Step 3: Add Private Key to GitHub Secrets

1. Go to your GitHub repository
2. Click on "Settings" tab
3. Click on "Secrets and variables" in the left sidebar
4. Click "Actions"
5. Click "New repository secret"
6. Name it `SSH_PRIVATE_KEY`
7. Paste the contents of your private key file (`~/.ssh/github-actions`)
8. Click "Add secret"

To get your private key content:
```bash
# Display private key content
cat ~/.ssh/github-actions
```

### Step 4: Configure Coolify

1. Access your Coolify dashboard
2. Add a new project
3. Point it to the `/root/rawfade` directory on your VPS
4. Coolify will automatically detect the docker-compose.yml file
5. Configure your domain (rawfadeclothing.com) in Coolify
6. Let Coolify handle SSL certificates through its integrated Traefik

## How It Works

1. When you push to the `main` branch, GitHub Actions:
   - Connects to your VPS using SSH key authentication
   - Syncs your latest code to `/root/rawfade`
   - Runs `docker compose up -d --build` to rebuild and restart your app

2. Coolify automatically:
   - Detects the running container
   - Manages the service through its integrated Traefik
   - Handles SSL certificates for your domain
   - Provides monitoring and deployment history

## Test the Deployment

Make a small change to your code and push it to the main branch:

```bash
git add .
git commit -m "Test automated deployment"
git push origin main
```

Then:
1. Check GitHub Actions progress in your repository's "Actions" tab
2. Monitor deployment in Coolify dashboard
3. Visit https://rawfadeclothing.com to see your updated app

## Troubleshooting

### If GitHub Actions Fails
- Verify SSH key is correctly added to GitHub Secrets
- Check that VPS is accessible and SSH service is running
- Ensure the private key doesn't have extra spaces or line breaks when copied

### If Site Is Not Accessible
- Check that DNS records point to 89.116.20.32
- Verify Coolify has correctly configured your domain
- Check Coolify logs for any deployment issues

### If Coolify Doesn't Detect the Service
- Make sure docker-compose.yml is in the root of /root/rawfade
- Restart the Coolify agent:
  ```bash
  ssh root@89.116.20.32
  coolify self-update
  ```

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
docker compose down
docker compose up -d --build
```

This setup ensures that every time you push code to the main branch of your repository, your application at https://rawfadeclothing.com is automatically updated with zero manual steps required.