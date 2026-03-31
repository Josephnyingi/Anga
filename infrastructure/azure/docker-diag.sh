#!/bin/bash
# Docker diagnostic script
OUTPUT="docker-diag.txt"

{
  echo "===== DOCKER VERSION ====="
  docker --version 2>&1 || echo "ERROR: Docker not found or not running"

  echo ""
  echo "===== DOCKER RUNNING? ====="
  docker info 2>&1 | head -5 || echo "ERROR: Docker daemon not running"

  echo ""
  echo "===== BUILD/WEB FILES ====="
  ls -lh apps/web/build/web/ 2>/dev/null || echo "ERROR: build/web not found"

  echo ""
  echo "===== DOCKERFILE.PREBUILT ====="
  cat apps/web/Dockerfile.prebuilt 2>/dev/null || echo "ERROR: Dockerfile.prebuilt not found"

  echo ""
  echo "===== ACR LOGIN TEST ====="
  az acr login --name angaweatheracr 2>&1 | tail -5

  echo ""
  echo "===== DOCKER BUILD TEST (dry run) ====="
  docker build \
    --platform linux/amd64 \
    -f apps/web/Dockerfile.prebuilt \
    -t anga-web-test:latest \
    apps/web/ 2>&1 | tail -20

} | tee "$OUTPUT"

echo ""
echo "✅ Diagnostics saved to docker-diag.txt"
