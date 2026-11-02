@description('Name of the action group.')
param name string

@description('Short name shown in SMS/email subjects (<= 12 chars).')
@maxLength(12)
param shortName string

@description('Email address that receives alert notifications.')
param notificationEmail string

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: name
  location: 'global'
  properties: {
    groupShortName: shortName
    enabled: true
    emailReceivers: [
      {
        name: 'ops-email'
        emailAddress: notificationEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

output id string = actionGroup.id
