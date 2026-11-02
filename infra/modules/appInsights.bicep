@description('Name of the Application Insights component.')
param name string

@description('Azure region.')
param location string

@description('Resource id of the workspace to back this component (workspace-based App Insights).')
param workspaceId string

resource component 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspaceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output connectionString string = component.properties.ConnectionString
output instrumentationKey string = component.properties.InstrumentationKey
