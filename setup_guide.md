# Automated Deployment Setup Guide

## Prerequisites
- VPS with Docker and Docker Compose installed
- Domain pointing to VPS IP (rawfadeclothing.com)
- GitHub repository with this project

## Step 1: Generate SSH Key Pair
On your local machine:
```bash
ssh-keygen -t rsa -b 4096 -C "github-deploy@rawfadeclothing.com" -f ~/.ssh/github_deploy
```

## Step 2: Add Public Key to VPS
Copy the public key to your VPS:
```bash
ssh-copy-id -i ~/.ssh/github_deploy.pub root@89.116.20.32
```

## Step 3: Add Private Key to GitHub Secrets
1. Go to your GitHub repository
2. Settings > Secrets and variables > Actions
3. Add secrets:
   - `DEPLOY_KEY`: Contents of `~/.ssh/github_deploy` (private key)
   - `VPS_HOST`: `89.116.20.32`

## Step 4: Initialize VPS Directory
SSH to your VPS:
```bash
ssh root@89.116.20.32
mkdir -p /root/rawfade
cd /root/rawfade
```

Create the external network:
```bash
docker network create web
```

Copy all files to VPS:
```bash
# From your local machine (run in project root)
scp -r . root@89.116.20.32:/root/rawfade/
```

## Step 4.5: Manual Deployment (Optional)
On VPS, run the deployment script:
```bash
cd /root/rawfade
chmod +x deploy_vps.sh
./deploy_vps.sh
```

## Step 5: Update Traefik Email
In docker-compose.yml, replace `your-email@example.com` with your actual email.

## Step 6: Push to GitHub
Commit and push the changes to the main branch. The deployment will trigger automatically.

## Step 7: Verify Deployment
After deployment, check:
- App accessible at https://rawfadeclothing.com
- Traefik dashboard at http://89.116.20.32:8080 (if needed)

## Notes
- The app runs on port 8080 inside the container
- Traefik handles SSL certificates automatically
- Redeployment happens on every push to main branch
