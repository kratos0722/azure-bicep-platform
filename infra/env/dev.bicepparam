using '../main.bicep'

param namePrefix = 'saasplat'
param environmentName = 'dev'
param appServiceSku = 'S1'
param sqlDatabaseSku = 'S0'
param sqlAdminLogin = 'sqladmin'
param notificationEmail = 'devops-alerts@example.com'
// Never hardcode secrets. The pipeline sets SQL_ADMIN_PASSWORD from a secret/Key Vault.
param sqlAdminPassword = readEnvironmentVariable('SQL_ADMIN_PASSWORD', 'set-in-pipeline')
