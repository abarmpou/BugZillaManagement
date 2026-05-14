#!/bin/bash

set -e

site_name="bugzilla"

DB_CONTAINER="${site_name}_db"
APP_CONTAINER="${site_name}_app"

DB_NAME="${site_name}_db"
DB_USER="${site_name}_user"
DB_PASSWORD="password"
DB_ROOT_PASSWORD="root-password"

# ----------------------------
# Install Docker if needed
# ----------------------------
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing..."

    apt-get update
    apt-get install -y docker.io

    systemctl enable docker
    systemctl start docker
fi

# ----------------------------
# Pull images
# ----------------------------
docker pull mariadb:latest
docker pull dklassen/bugzilla:latest

# ----------------------------
# Create local folders
# ----------------------------
if [ -d "$site_name" ]; then
    echo "Folder '$site_name' already exists."
else
    mkdir -p "$site_name"/{html,database}
fi

# ----------------------------
# Find available port
# ----------------------------
port=8101

while docker ps --format '{{.Ports}}' | grep -q ":${port}->"; do
    port=$((port + 1))
done

echo "Using port: $port"

# ----------------------------
# Create Docker network
# ----------------------------
docker network create "${site_name}_network" 2>/dev/null || true

# ----------------------------
# Start MariaDB
# ----------------------------
docker run -d \
  --name "$DB_CONTAINER" \
  --network "${site_name}_network" \
  --restart unless-stopped \
  -e MYSQL_ROOT_PASSWORD="$DB_ROOT_PASSWORD" \
  -e MYSQL_DATABASE="$DB_NAME" \
  -e MYSQL_USER="$DB_USER" \
  -e MYSQL_PASSWORD="$DB_PASSWORD" \
  -v "$(pwd)/$site_name/database:/var/lib/mysql" \
  mariadb:latest

echo "Waiting for MariaDB to initialize..."
sleep 20

# ----------------------------
# Start Bugzilla
# ----------------------------
docker run -d \
  --name "$APP_CONTAINER" \
  --network "${site_name}_network" \
  --restart unless-stopped \
  -p "$port:80" \
  -v "$(pwd)/$site_name/html:/var/www/html" \
  -e DB_HOST="$DB_CONTAINER" \
  -e DB_NAME="$DB_NAME" \
  -e DB_USER="$DB_USER" \
  -e DB_PASSWORD="$DB_PASSWORD" \
  dklassen/bugzilla:latest

echo ""
echo "Bugzilla should now be available at:"
echo "http://localhost:$port"