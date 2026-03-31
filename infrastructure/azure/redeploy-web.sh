#!/bin/bash
# Rebuild ONLY the web (Flutter+nginx) image and restart ACI
# Run from project root: bash infrastructure/azure/redeploy-web.sh
set -e

RESOURCE_GROUP="anga-rg"
ACR_NAME="angaweatheracr"
CONTAINER_GROUP="anga-cg"
ACR_LOGIN_SERVER="${ACR_NAME}.azurecr.io"

echo "🔐 Logging into Azure Container Registry..."
az acr login --name "$ACR_NAME"

echo "🏗️  Building web image (Flutter + nginx)..."
docker build \
  --platform linux/amd64 \
  -f apps/web/Dockerfile.prebuilt \
  -t "${ACR_LOGIN_SERVER}/anga-web:latest" \
  apps/web/

echo "📤 Pushing web image to ACR..."
docker push "${ACR_LOGIN_SERVER}/anga-web:latest"

echo "🔄 Restarting container group to pull new image..."
az container restart \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CONTAINER_GROUP"

echo ""
echo "⏳ Waiting 30 seconds for containers to come back up..."
sleep 30

echo ""
echo "📊 Container status:"
az container show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CONTAINER_GROUP" \
  --query "containers[].{name:name,state:instanceView.currentState.state,restarts:instanceView.restartCount}" \
  --output table

echo ""
echo "✅ Done! Visit: http://anga-weather.japaneast.azurecontainer.io"
