// =============================================================================
// main.bicep — resource-group-scoped deployment of a small SaaS platform:
//   Log Analytics + Application Insights, a Windows App Service, Azure SQL,
//   a Key Vault, and an Azure Monitor alert on app 5xx errors.
// Deploy with:
//   az deployment group create -g <rg> -f infra/main.bicep -p infra/env/dev.bicepparam
// =============================================================================

targetScope = 'resourceGroup'

@description('Short base name for all resources (letters/numbers).')
@minLength(3)
@maxLength(12)
param namePrefix string = 'saasplat'

@description('Environment discriminator, e.g. dev / stg / prod.')
param environmentName string = 'dev'

@description('Azure region; defaults to the resource group location.')
param location string = resourceGroup().location

@description('App Service plan SKU.')
param appServiceSku string = 'S1'

@description('Azure SQL database SKU.')
param sqlDatabaseSku string = 'S0'

@description('SQL administrator login.')
param sqlAdminLogin string

@secure()
@description('SQL administrator password (supply from a pipeline secret).')
param sqlAdminPassword string

// A short, deterministic suffix keeps globally-unique names stable per RG.
var suffix = uniqueString(resourceGroup().id)
var baseName = '${namePrefix}-${environmentName}'

module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    name: '${baseName}-law'
    location: location
  }
}

module appInsights 'modules/appInsights.bicep' = {
  name: 'appInsights'
  params: {
    name: '${baseName}-ai'
    location: location
    workspaceId: logAnalytics.outputs.id
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    planName: '${baseName}-plan'
    siteName: '${baseName}-api-${suffix}'
    location: location
    skuName: appServiceSku
    appInsightsConnectionString: appInsights.outputs.connectionString
  }
}

module sql 'modules/sqlDatabase.bicep' = {
  name: 'sql'
  params: {
    serverName: toLower('${baseName}-sql-${suffix}')
    databaseName: '${namePrefix}db'
    location: location
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    skuName: sqlDatabaseSku
  }
}

module keyVault 'modules/keyVault.bicep' = {
  name: 'keyVault'
  params: {
    name: take('${namePrefix}kv${suffix}', 24)
    location: location
  }
}

module http5xxAlert 'modules/alerts.bicep' = {
  name: 'http5xxAlert'
  params: {
    name: '${baseName}-http5xx'
    siteId: appService.outputs.siteId
  }
}

output appHostName string = appService.outputs.defaultHostName
output sqlServerFqdn string = sql.outputs.serverFqdn
output appInsightsConnectionString string = appInsights.outputs.connectionString
output keyVaultUri string = keyVault.outputs.uri
