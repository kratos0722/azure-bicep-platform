@description('Name of the Key Vault. Must be globally unique, 3-24 chars.')
@maxLength(24)
param name string

@description('Azure region.')
param location string

@description('Azure AD tenant id that owns the vault.')
param tenantId string = subscription().tenantId

resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: true
    publicNetworkAccess: 'Enabled'
  }
}

output id string = vault.id
output name string = vault.name
output uri string = vault.properties.vaultUri
