@description('Name of the Log Analytics workspace.')
param name string

@description('Azure region.')
param location string

@description('Data retention in days.')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

output id string = workspace.id
output name string = workspace.name
