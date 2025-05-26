#!/bin/bash

echo "🚨 WARNING: This will stop and delete ALL Docker containers, images, volumes, and user-defined networks."
read -p "Are you sure you want to continue? (y/N): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 1
fi

echo "🛑 Stopping all containers..."
docker stop $(docker ps -aq) 2>/dev/null

echo "🗑 Removing all containers..."
docker rm -f $(docker ps -aq) 2>/dev/null

echo "🧼 Removing all images..."
docker rmi -f $(docker images -q) 2>/dev/null

echo "🧹 Removing all volumes..."
docker volume rm $(docker volume ls -q) 2>/dev/null

echo "🌐 Removing all user-defined networks..."
docker network rm $(docker network ls -q | grep -vE 'bridge|host|none') 2>/dev/null

echo "🧽 Running final system prune..."
docker system prune -a --volumes -f

echo "✅ Docker has been reset."
