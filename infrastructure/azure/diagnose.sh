#!/bin/bash
# ANGA Azure Deployment Diagnostics
# Run: bash infrastructure/azure/diagnose.sh
# Output saved to: azure-diag.txt

OUTPUT="azure-diag.txt"
echo "Running ANGA diagnostics..."

{
  echo "===== CONTAINER GROUP STATUS ====="
  az container show --resource-group anga-rg --name anga-cg \
    --query "{state:instanceView.state,ip:ipAddress.ip,fqdn:ipAddress.fqdn,provisioningState:provisioningState}" \
    --output table

  echo ""
  echo "===== CONTAINER STATES & RESTARTS ====="
  az container show --resource-group anga-rg --name anga-cg \
    --query "containers[].{name:name,state:instanceView.currentState.state,exitCode:instanceView.currentState.exitCode,restarts:instanceView.restartCount}" \
    --output table

  echo ""
  echo "===== HTTP TEST: Web (port 80) via domain ====="
  curl -sv --max-time 10 http://anga-weather.japaneast.azurecontainer.io/ 2>&1 | head -40

  echo ""
  echo "===== HTTP TEST: Web (port 80) via IP ====="
  curl -sv --max-time 10 http://20.27.8.32/ 2>&1 | head -40

  echo ""
  echo "===== HTTP TEST: Backend (port 8000) via IP ====="
  curl -sv --max-time 10 http://20.27.8.32:8000/ 2>&1 | head -40

  echo ""
  echo "===== WEB CONTAINER LOGS (last 50 lines) ====="
  az container logs --resource-group anga-rg --name anga-cg --container-name web --tail 50

  echo ""
  echo "===== BACKEND CONTAINER LOGS (last 50 lines) ====="
  az container logs --resource-group anga-rg --name anga-cg --container-name backend --tail 50

} | tee "$OUTPUT"

echo ""
echo "✅ Diagnostics saved to $OUTPUT"
