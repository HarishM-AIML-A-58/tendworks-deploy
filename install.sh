#!/bin/bash
set -e

echo "🚀 Starting Tendworks HRMS HIGH-PERFORMANCE Instant Deployment..."

# 1. System Pre-flight & Optimization
echo "🛠️ Optimizing System Settings..."
# Increase file descriptor limits for high concurrency
if ! grep -q "soft nofile 65535" /etc/security/limits.conf; then
    echo "* soft nofile 65535" >> /etc/security/limits.conf
    echo "* hard nofile 65535" >> /etc/security/limits.conf
fi

# 2. Install Docker if not present
if ! [ -x "$(command -v docker)" ]; then
  echo "📦 Installing Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
fi

# 3. Setup Configuration
read -p "🌐 Enter Domain (e.g. hrms.tendworks.com): " DOMAIN
read -p "📧 Enter Email for SSL: " EMAIL

DB_PASSWORD=$(openssl rand -hex 16)
SECRET_KEY=$(openssl rand -hex 32)
CPU_CORES=$(nproc)
# Recommended Gunicorn workers: (2 * cores) + 1
G_WORKERS=$(( (CPU_CORES * 2) + 1 ))

cat <<ENV > .env
DOMAIN=$DOMAIN
EMAIL=$EMAIL
DB_PASSWORD=$DB_PASSWORD
SECRET_KEY=$SECRET_KEY
GUNICORN_WORKERS=$G_WORKERS
ENV

echo "📄 Created .env with optimized worker count: $G_WORKERS"

# 4. Pull and Launch with Resource Priorities
echo "⚓ Pulling optimized images and booting up..."
docker compose pull
docker compose up -d

echo "⚡ Applying Post-launch Resource Controls..."
# Ensure the web container gets high priority even if system is busy
docker update --cpu-shares 2048 $(docker compose ps -q web)
docker update --cpu-shares 2048 $(docker compose ps -q celery)
docker update --cpu-shares 512 $(docker compose ps -q traefik)

echo "✅ High-Performance Deployment Finished!"
echo "🔗 Access your HRMS at: https://$DOMAIN"
echo "📊 System optimized for $CPU_CORES cores with $G_WORKERS workers."
