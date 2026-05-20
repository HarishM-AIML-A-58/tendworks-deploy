#!/bin/bash
set -e

echo "🚀 Starting Tendworks HRMS Instant Deployment..."

# 1. Install Docker if not present
if ! [ -x "$(command -v docker)" ]; then
  echo "📦 Installing Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
fi

# 2. Setup Configuration
read -p "🌐 Enter Domain (e.g. hrms.tendworks.com): " DOMAIN
read -p "📧 Enter Email for SSL: " EMAIL

DB_PASSWORD=$(openssl rand -hex 16)
SECRET_KEY=$(openssl rand -hex 32)

cat <<ENV > .env
DOMAIN=$DOMAIN
EMAIL=$EMAIL
DB_PASSWORD=$DB_PASSWORD
SECRET_KEY=$SECRET_KEY
ENV

echo "📄 Created .env with secure credentials."

# 3. Pull and Launch
echo "⚓ Pulling images and booting up..."
docker compose pull
docker compose up -d

echo "✅ Deployment finished! Point your IP to this server in Cloudflare."
echo "🔗 Access your HRMS at: https://$DOMAIN"
