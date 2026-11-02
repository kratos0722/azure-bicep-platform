# azure-bicep-platform

Infrastructure-as-Code for a small SaaS platform on **Azure**, authored in
**Bicep** and shipped through an **Azure DevOps** pipeline — with a SQL Database
Project (**DACPAC**), Azure Monitor alerting, and a MSSQL **backup & disaster
recovery** runbook.

> Original reference implementation. No proprietary code or secrets; sample
> values are synthetic.

## What it provisions

`infra/main.bicep` (resource-group scope) composes six modules:

| Module | Resource | Notes |
| ------ | -------- | ----- |
| `logAnalytics.bicep` | Log Analytics workspace | 30-day retention, resource-permission access |
| `appInsights.bicep` | Application Insights | workspace-based, wired into the app |
| `appService.bicep` | Windows App Service + plan | HTTPS-only, TLS 1.2, `v8.0`, Always On |
| `sqlDatabase.bicep` | Azure SQL server + database | TLS 1.2, geo-redundant backups, firewall rule |
| `keyVault.bicep` | Key Vault | RBAC auth, soft-delete + purge protection |
| `alerts.bicep` | Azure Monitor metric alert | fires on app HTTP 5xx |

Secrets are never hardcoded: `sqlAdminPassword` is a `@secure()` parameter
supplied from a pipeline secret (or a Key Vault reference) at deploy time.

## Repository layout

```
infra/
  main.bicep              # orchestrator (resource-group scope)
  bicepconfig.json        # linter rules
  modules/                # one resource concern per module
  env/                    # dev.bicepparam, prod.bicepparam
db/
  SaasDb.sqlproj          # SQL Database Project (Microsoft.Build.Sql SDK)
  Tables/                 # schema as code -> builds to a DACPAC
azure-pipelines.yml       # Azure DevOps: validate -> deploy infra -> publish DACPAC
scripts/                  # deploy.sh / deploy.ps1 (az deployment group create)
docs/                     # backup-dr-runbook.md, monitoring.md
.github/workflows/ci.yml  # validates Bicep + builds the DACPAC on every push/PR
```

## Validate locally

```bash
az bicep build --file infra/main.bicep        # compile + lint all modules
az deployment group what-if -g <rg> \
  --template-file infra/main.bicep \
  --parameters infra/env/dev.bicepparam        # preview changes (requires login)
```

Build the database project to a DACPAC (cross-platform, no SSDT required):

```bash
dotnet build db/SaasDb.sqlproj -c Release
```

## Deploy

```bash
export SQL_ADMIN_PASSWORD='<from your secret store>'
./scripts/deploy.sh rg-saasplat-dev dev
```

## CI

GitHub Actions ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) runs on
every push and PR:

- **Validate Bicep** — `az bicep build` of `main.bicep` and both parameter files.
- **Build DACPAC** — `dotnet build` of the SQL project, asserting the DACPAC is
  produced.

The Azure DevOps pipeline ([`azure-pipelines.yml`](azure-pipelines.yml)) adds the
deploy stages (`what-if` → `az deployment group create` → `SqlAzureDacpacDeployment`)
that run against a real subscription via a service connection.

## Tech

Bicep · Azure (App Service, Azure SQL, Key Vault, Monitor, Log Analytics) ·
Azure DevOps · Microsoft.Build.Sql (DACPAC) · GitHub Actions

## License

MIT — see [LICENSE](LICENSE).
