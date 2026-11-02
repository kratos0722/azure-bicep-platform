@description('Name of the metric alert.')
param name string

@description('Resource id of the App Service to monitor.')
param siteId string

@description('Metric to evaluate, e.g. Http5xx or HttpResponseTime.')
param metricName string = 'Http5xx'

@description('Aggregation over the window: Total, Average, Maximum, etc.')
param timeAggregation string = 'Total'

@description('Comparison operator.')
@allowed([
  'GreaterThan'
  'GreaterThanOrEqual'
  'LessThan'
  'LessThanOrEqual'
])
param operator string = 'GreaterThan'

@description('Threshold the aggregated metric is compared against.')
param threshold int = 10

@description('Alert severity (0 = critical … 4 = verbose).')
@minValue(0)
@maxValue(4)
param severity int = 2

@description('Optional action group id to notify when the alert fires.')
param actionGroupId string = ''

var actions = empty(actionGroupId) ? [] : [
  {
    actionGroupId: actionGroupId
  }
]

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: name
  location: 'global'
  properties: {
    severity: severity
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
          name: 'Metric1'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: metricName
          operator: operator
          threshold: threshold
          timeAggregation: timeAggregation
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: actions
  }
}

output alertId string = metricAlert.id
