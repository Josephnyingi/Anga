#!/bin/bash
# =============================================================================
# ANGA — Azure Container Instances Deployment Script
# =============================================================================
# Builds Docker images, pushes to Azure Container Registry,
# and deploys both containers to ACI with one public URL.
#
# Prerequisites:
#   - Docker Desktop running
#   - Azure CLI installed  (brew install azure-cli)
#   - Azure account with active subscription
#
# Usage:
#   cd infrastructure/azure
#   chmod +x deploy.sh
#   ./deploy.sh
# =============================================================================

set -e  # Exit immediately on any error

# ── Config ────────────────────────────────────────────────────────────────────
RESOURCE_GROUP="anga-rg"
LOCATION="japaneast"
ACR_NAME="angaweatheracr"          # Must be globally unique, lowercase, no hyphens
CONTAINER_GROUP="anga-cg"
DNS_LABEL="anga-weather"           # → anga-weather.japaneast.azurecontainer.io

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${NC}"; }
error()   { echo -e "${RED}❌ $1${NC}"; exit 1; }

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        ANGA — Azure Deployment                  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ── Check prerequisites ───────────────────────────────────────────────────────
info "Checking prerequisites..."

command -v docker &>/dev/null || error "Docker not found. Install Docker Desktop."
docker info &>/dev/null        || error "Docker Desktop is not running. Please start it."
command -v az &>/dev/null      || error "Azure CLI not found. Run: brew install azure-cli"

success "Docker and Azure CLI found"

# ── Check required env vars ───────────────────────────────────────────────────
if [[ -z "$GROQ_API_KEY" || -z "$HF_TOKEN" ]]; then
  warn "GROQ_API_KEY and/or HF_TOKEN not set in environment."
  warn "The backend will start but AI features will use fallback mode."
  warn "To set them: export GROQ_API_KEY=your_key && export HF_TOKEN=your_token"
  echo ""
fi

# ── Step 1: Azure login ───────────────────────────────────────────────────────
info "Step 1/6 — Azure login..."
if ! az account show &>/dev/null; then
  az login
fi
SUBSCRIPTION=$(az account show --query name -o tsv)
success "Logged in — Subscription: $SUBSCRIPTION"

# ── Step 2: Create Resource Group ────────────────────────────────────────────
info "Step 2/6 — Creating resource group '$RESOURCE_GROUP' in $LOCATION..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none
success "Resource group ready"

# ── Step 3: Create Azure Container Registry ───────────────────────────────────
info "Step 3/6 — Creating Container Registry '$ACR_NAME'..."
az acr create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACR_NAME" \
  --sku Basic \
  --admin-enabled true \
  --output none 2>/dev/null || warn "ACR already exists — skipping creation"

ACR_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
ACR_USER=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
ACR_PASS=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)
success "ACR ready — $ACR_SERVER"

# ── Step 4: Docker login to ACR ───────────────────────────────────────────────
info "Step 4/6 — Logging Docker into ACR..."
echo "$ACR_PASS" | docker login "$ACR_SERVER" --username "$ACR_USER" --password-stdin
success "Docker logged into ACR"

# ── Step 5: Build and push images ─────────────────────────────────────────────
info "Step 5/6 — Building and pushing Docker images..."

# Backend
info "  Building backend image..."
docker build \
  --platform linux/amd64 \
  -t "$ACR_SERVER/anga-backend:latest" \
  "$REPO_ROOT/apps/backend"
docker push "$ACR_SERVER/anga-backend:latest"
success "  Backend image pushed"

# Web (Flutter builds inside Docker — no local Flutter needed)
info "  Building web image (Flutter builds inside Docker, ~5 min)..."
docker build \
  --platform linux/amd64 \
  -t "$ACR_SERVER/anga-web:latest" \
  "$REPO_ROOT/apps/web"
docker push "$ACR_SERVER/anga-web:latest"
success "  Web image pushed"

# ── Step 6: Deploy to ACI ─────────────────────────────────────────────────────
info "Step 6/6 — Deploying to Azure Container Instances..."

# Delete existing container group if it exists (for redeployments)
az container delete \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CONTAINER_GROUP" \
  --yes \
  --output none 2>/dev/null || true

az container create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CONTAINER_GROUP" \
  --location "$LOCATION" \
  --os-type Linux \
  --ip-address Public \
  --dns-name-label "$DNS_LABEL" \
  --ports 80 8000 \
  --registry-login-server "$ACR_SERVER" \
  --registry-username "$ACR_USER" \
  --registry-password "$ACR_PASS" \
  --containers-config "[
    {
      \"name\": \"web\",
      \"image\": \"$ACR_SERVER/anga-web:latest\",
      \"ports\": [{\"port\": 80}],
      \"resources\": {\"requests\": {\"cpu\": 1, \"memoryInGb\": 1.5}},
      \"environmentVariables\": [
        {\"name\": \"NODE_ENV\", \"value\": \"production\"}
      ]
    },
    {
      \"name\": \"backend\",
      \"image\": \"$ACR_SERVER/anga-backend:latest\",
      \"ports\": [{\"port\": 8000}],
      \"resources\": {\"requests\": {\"cpu\": 1, \"memoryInGb\": 1.5}},
      \"environmentVariables\": [
        {\"name\": \"API_HOST\",        \"value\": \"0.0.0.0\"},
        {\"name\": \"API_PORT\",        \"value\": \"8000\"},
        {\"name\": \"PYTHONPATH\",      \"value\": \".\"},
        {\"name\": \"PYTHONUNBUFFERED\",\"value\": \"1\"},
        {\"name\": \"GROQ_API_KEY\",    \"secureValue\": \"${GROQ_API_KEY:-not_set}\"},
        {\"name\": \"HF_TOKEN\",        \"secureValue\": \"${HF_TOKEN:-not_set}\"}
      ]
    }
  ]" \
  --output none

success "Deployment complete!"

# ── Print results ─────────────────────────────────────────────────────────────
FQDN=$(az container show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CONTAINER_GROUP" \
  --query ipAddress.fqdn -o tsv)

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  🎉  ANGA IS LIVE ON AZURE!                                 ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║  🌐  Web App:   http://$FQDN${NC}"
echo -e "${GREEN}║  ⚙️   API Docs:  http://$FQDN:8000/docs${NC}"
echo -e "${GREEN}║  💚  Health:    http://$FQDN:8000/health${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║  📱  Use the web app URL in your QR code!                   ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}⚠️  Update QR card URL:${NC}"
echo "   docs/showcase/qr-card.html → set ANGA_URL = \"http://$FQDN\""
echo ""
