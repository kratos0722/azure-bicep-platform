using '../main.bicep'

param namePrefix = 'saasplat'
param environmentName = 'prod'
param appServiceSku = 'P1v3'
param sqlDatabaseSku = 'GP_S_Gen5_2'
param sqlAdminLogin = 'sqladmin'
// Never hardcode secrets. The pipeline sets SQL_ADMIN_PASSWORD from a secret/Key Vault.
param sqlAdminPassword = readEnvironmentVariable('SQL_ADMIN_PASSWORD', 'set-in-pipeline')
