#!/usr/bin/env bash
# Deploy the platform to a resource group.
# Usage: SQL_ADMIN_PASSWORD='***' ./scripts/deploy.sh <resource-group> [dev|prod]
set -euo pipefail

RG="${1:?resource group required}"
ENVIRONMENT="${2:-dev}"

: "${SQL_ADMIN_PASSWORD:?set SQL_ADMIN_PASSWORD in the environment}"

echo "Validating template..."
az bicep build --file infra/main.bicep

echo "What-if against $RG ($ENVIRONMENT)..."
az deployment group what-if \
  --resource-group "$RG" \
  --template-file infra/main.bicep \
  --parameters "infra/env/${ENVIRONMENT}.bicepparam"

echo "Deploying to $RG ($ENVIRONMENT)..."
az deployment group create \
  --resource-group "$RG" \
  --template-file infra/main.bicep \
  --parameters "infra/env/${ENVIRONMENT}.bicepparam"
