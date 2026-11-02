@description('Name of the logical SQL server. Must be globally unique.')
param serverName string

@description('Name of the database.')
param databaseName string

@description('Azure region.')
param location string

@description('SQL administrator login name.')
param administratorLogin string

@secure()
@description('SQL administrator password. Supply from a pipeline secret / Key Vault.')
param administratorLoginPassword string

@description('Database SKU, e.g. S0, S1, GP_S_Gen5_2.')
param skuName string = 'S0'

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

resource database 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: skuName
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    // 7 days of point-in-time restore is the default; see the DR runbook for LTR.
    requestedBackupStorageRedundancy: 'Geo'
  }
}

// Allow other Azure services (0.0.0.0) so the App Service can reach the database.
resource allowAzureServices 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
  parent: sqlServer
  name: 'AllowAllAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

output serverFqdn string = sqlServer.properties.fullyQualifiedDomainName
output databaseId string = database.id
output databaseName string = database.name
