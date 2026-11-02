@description('Name of the App Service plan.')
param planName string

@description('Name of the App Service (web app). Must be globally unique.')
param siteName string

@description('Azure region.')
param location string

@description('App Service plan SKU, e.g. S1, P1v3.')
param skuName string = 'S1'

@description('Application Insights connection string wired into app settings.')
param appInsightsConnectionString string

// Windows plan (reserved: false) — the resume targets IIS-hosted .NET workloads.
resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: planName
  location: location
  sku: {
    name: skuName
  }
  properties: {
    reserved: false
  }
}

resource site 'Microsoft.Web/sites@2023-12-01' = {
  name: siteName
  location: location
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      http20Enabled: true
      netFrameworkVersion: 'v8.0'
      alwaysOn: true
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
      ]
    }
  }
}

output siteId string = site.id
output defaultHostName string = site.properties.defaultHostName
