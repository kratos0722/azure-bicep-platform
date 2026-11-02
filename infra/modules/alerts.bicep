@description('Name of the metric alert.')
param name string

@description('Resource id of the App Service to monitor.')
param siteId string

@description('Threshold for server-side 5xx responses over the evaluation window.')
param http5xxThreshold int = 10

// Fires when the web app returns too many 5xx responses in a 5-minute window.
resource http5xxAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: name
  location: 'global'
  properties: {
    severity: 2
    enabled: true
    scopes: [
      siteId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'Http5xx'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: 'Http5xx'
          operator: 'GreaterThan'
          threshold: http5xxThreshold
          timeAggregation: 'Total'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
  }
}

output alertId string = http5xxAlert.id
