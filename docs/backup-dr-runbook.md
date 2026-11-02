# MSSQL / Azure SQL — Backup & Disaster Recovery Runbook

Operational runbook for protecting and recovering the `SaasDb` database. Targets
Azure SQL Database (the `sqlDatabase.bicep` module), with notes that also apply
to IIS-hosted MSSQL instances.

## Objectives

| Metric | Target (prod) | Mechanism |
| ------ | ------------- | --------- |
| RPO (max data loss) | ≤ 5 min | Automated transaction-log backups (every 5–10 min) |
| RTO (max downtime)  | ≤ 1 hour | Point-in-time restore or failover group |
| Retention (PITR)    | 7 days   | Default automated backups |
| Retention (LTR)     | 12 months | Long-term retention policy |

## 1. Backups (what runs automatically)

Azure SQL takes backups with no agent to manage:

- **Full** — weekly
- **Differential** — every 12–24 h
- **Transaction log** — every 5–10 min (drives the ≤ 5 min RPO)

Backup storage redundancy is set to **Geo** in `sqlDatabase.bicep`
(`requestedBackupStorageRedundancy: 'Geo'`), so backups survive a regional
outage.

### Long-term retention (LTR)

```bash
az sql db ltr-policy set \
  --resource-group rg-saasplat-prod \
  --server <server> --name saasplatdb \
  --weekly-retention P4W --monthly-retention P12M --yearly-retention P5Y --week-of-year 1
```

## 2. Point-in-time restore (most common recovery)

Restores to a **new** database (the original is never overwritten); repoint the
app once verified.

```bash
az sql db restore \
  --resource-group rg-saasplat-prod \
  --server <server> --name saasplatdb \
  --dest-name saasplatdb-restored \
  --time "2026-11-03T02:30:00Z"
```

Then swap the App Service connection string (Key Vault reference) to the restored
database and validate before deleting the old one.

## 3. Regional outage — geo-restore / failover group

- **Geo-restore** (RRO, no pre-provisioning): restore the latest geo-replicated
  backup into the paired region.
- **Failover group** (lowest RTO): pre-configured secondary; DNS-based listener
  means the app's connection string does not change on failover.

```bash
az sql failover-group set-primary \
  --resource-group rg-saasplat-prod \
  --server <secondary-server> --name saasplat-fog
```

## 4. Self-hosted MSSQL (IIS-hosted apps)

For a classic MSSQL instance behind IIS:

- Nightly **FULL**, hourly **DIFF**, log backups every 15 min to a geo-redundant
  share; verify with `RESTORE VERIFYONLY`.
- Automate with SQL Agent jobs or Ola Hallengren's maintenance solution.
- **Test restores monthly** — an untested backup is not a backup.

## 5. Quarterly DR drill (checklist)

1. Trigger a PITR to a scratch database.
2. Run smoke queries (row counts, latest `CreatedAt`).
3. Repoint a staging slot at the restored DB; run health checks.
4. Record actual RTO/RPO vs. target; file gaps as issues.
