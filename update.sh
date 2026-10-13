#!/bin/bash
set -e

cd /var/docker/storytold

echo "=== Pruning old build cache and images ==="
docker buildx prune -f
docker image prune -f

echo "=== Building apps one at a time ==="
APPS=(photocraft vectorcraft lightcraft printcraft effectcraft designcraft filmcraft)

for app in "${APPS[@]}"; do
    echo ""
    echo ">>> Building $app..."
    docker compose build --no-cache $app
    echo ">>> $app done"
done

echo ""
echo ">>> Building launcher..."
docker compose build launcher

echo ""
echo "=== Pruning dangling images after build ==="
docker image prune -f

echo ""
echo "=== Redeploying stack ==="
docker compose up -d

echo ""
echo "=== Done! ==="
docker compose ps
