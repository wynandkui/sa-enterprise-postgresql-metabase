# 07 — Reproduction checklist

This is a **manual reproduction checklist**, not a tested automated installer.

- [ ] Install and update Debian / Raspberry Pi environment.
- [ ] Install PostgreSQL 17 and create separate analytics and Metabase application databases.
- [ ] Review and apply [`sql/schema/sa_enterprise_schema_current.sql`](../sql/schema/sa_enterprise_schema_current.sql) in a fresh test database; the historical schema is not the deployed `tbl_` schema.
- [ ] Review the seven [original generator scripts](../sql/generators/) for table-name compatibility and execution dependencies before running them.
- [ ] Back up the empty or baseline database.
- [ ] Run master data generation, then orders, order items, invoices, invoice items, payments and status reconciliation.
- [ ] Confirm exactly 893,758 records across the 11 documented tables.
- [ ] Verify no orphan foreign keys, incorrect invoice totals or overpaid invoices.
- [ ] Run `ANALYZE`.
- [ ] Deploy Metabase using a PostgreSQL-backed application database.
- [ ] Create a read-only reporting role with only necessary grants.
- [ ] Add the analytics database to Metabase and sync metadata.
- [ ] Recreate the four reporting charts and four KPI cards.
- [ ] Add and map the reporting-period filter deliberately for every intended card.
- [ ] Verify chart and SQL question results.
- [ ] Back up both databases after completion.
- [ ] Verify no secrets or real data are present before publishing.

**Provided:** current schema DDL, historical pre-renaming schema, and seven original SQL generator files. **Not yet provided or validated:** a tested clean-install execution sequence, pinned Docker Compose configuration, and exported Metabase collections. Do not treat these sources as a verified automated installer.
