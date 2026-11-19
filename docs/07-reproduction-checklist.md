# 07 — Reproduction checklist

This is a **manual reproduction checklist**, not a tested automated installer.

- [ ] Install and update Debian / Raspberry Pi environment.
- [ ] Install PostgreSQL 17 and create separate analytics and Metabase application databases.
- [ ] Create the schema from a reviewed export of the original database.
- [ ] Obtain and review the original SQL generator scripts from `/home/wynand/sa-enterprise-generator/`.
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

**Not yet provided:** full original DDL, original executable generator SQL, pinned Docker Compose configuration and exported Metabase collections. These should be added from reviewed system exports, not reconstructed as if they were exact originals.
