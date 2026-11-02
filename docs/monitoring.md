# Monitoring & Observability

The platform ships observability as code: a Log Analytics workspace, a
workspace-based Application Insights component, and an Azure Monitor metric alert
on application 5xx errors — all provisioned by `infra/main.bicep`.

## Signals

| Layer | Source | Where |
| ----- | ------ | ----- |
| App telemetry (requests, deps, exceptions) | Application Insights | `appInsights.bicep` |
| Platform metrics (CPU, HTTP queue, 5xx) | App Service metrics | Azure Monitor |
| Logs (app + resource) | Log Analytics workspace | `logAnalytics.bicep` |
| SQL (DTU/vCore, deadlocks, storage) | Azure SQL metrics | Azure Monitor |

The App Service is wired to App Insights through the
`APPLICATIONINSIGHTS_CONNECTION_STRING` app setting, so no code change is needed
to collect request and dependency telemetry.

## Alerts

Provisioned today, both routed to an **action group** (`actionGroup.bicep`) that
emails the on-call address so a firing alert actually notifies someone:

- **HTTP 5xx** — more than 10 server errors in a 5-minute window
  (`alerts.bicep`, severity 2).
- **Response time** — average `HttpResponseTime` over 5 s in a 5-minute window
  (severity 3).

Recommended additions (same pattern, new `alerts.bicep` instances wired to the
same action group):

- App Service **CPU > 80%** for 15 min.
- Azure SQL **DTU/vCore > 85%** for 15 min.
- Availability test failure from App Insights.

## Useful KQL (Log Analytics)

Top failing requests in the last hour:

```kusto
requests
| where timestamp > ago(1h) and success == false
| summarize failures = count() by name, resultCode
| order by failures desc
```

Exception trend by type:

```kusto
exceptions
| where timestamp > ago(24h)
| summarize count() by type, bin(timestamp, 1h)
| render timechart
```

Dependency latency (P95):

```kusto
dependencies
| where timestamp > ago(1h)
| summarize p95 = percentile(duration, 95) by target
| order by p95 desc
```

## Dashboards

Pin the queries above to an Azure Portal shared dashboard, or build an Azure
Monitor Workbook per environment (dev/prod) scoped to the resource group.
