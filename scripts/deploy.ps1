<#
.SYNOPSIS
  Deploy the platform to a resource group.
.EXAMPLE
  $env:SQL_ADMIN_PASSWORD = '***'
  ./scripts/deploy.ps1 -ResourceGroup rg-saasplat-dev -Environment dev
#>
param(
    [Parameter(Mandatory = $true)][string]$ResourceGroup,
    [ValidateSet('dev', 'prod')][string]$Environment = 'dev'
)

$ErrorActionPreference = 'Stop'

if (-not $env:SQL_ADMIN_PASSWORD) {
    throw 'Set SQL_ADMIN_PASSWORD in the environment before deploying.'
}

Write-Host 'Validating template...'
az bicep build --file infra/main.bicep

Write-Host "What-if against $ResourceGroup ($Environment)..."
az deployment group what-if `
    --resource-group $ResourceGroup `
    --template-file infra/main.bicep `
    --parameters "infra/env/$Environment.bicepparam"

Write-Host "Deploying to $ResourceGroup ($Environment)..."
az deployment group create `
    --resource-group $ResourceGroup `
    --template-file infra/main.bicep `
    --parameters "infra/env/$Environment.bicepparam"
