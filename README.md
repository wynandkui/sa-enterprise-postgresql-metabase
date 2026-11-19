# South African Enterprise Demo — PostgreSQL 17 & Metabase

Documented Raspberry Pi 4 enterprise reporting demonstration using PostgreSQL 17 and Metabase. **All business data is synthetic.** Snapshot: 19 November 2026.

## Verified deployment
- Raspberry Pi 4, Debian 13 (trixie), OpenMediaVault 8.
- PostgreSQL 17 database: `sa_enterprise_demo`; Metabase application database: `metabase_app`.
- Metabase in Docker, accessible on the LAN at `http://192.168.0.188:3001` in the original deployment.
- Executive dashboard: **South African Enterprise — Executive Dashboard**.
- Reporting reader: `metabase_reader`, intended for read-only access.

## Record counts

| Relation | Records |
|---|---:|
| departments | 8 |
| customers | 10,000 |
| suppliers | 500 |
| products | 2,000 |
| employees | 250 |
| assets | 1,000 |
| sales_orders | 100,000 |
| sales_order_items | 300,000 |
| invoices | 100,000 |
| invoice_items | 300,000 |
| payments | 80,000 |
| **Total** | **893,758** |

The PostgreSQL relations are prefixed `tbl_` in the deployed schema. Four reporting views are prefixed `vw_`; four legacy aliases are prefixed `view_`.

## Documentation
1. [Architecture and schema](docs/01-architecture-and-schema.md)
2. [Sample-data generation](docs/02-data-generation.md)
3. [Metabase integration](docs/03-metabase.md)
4. [Dashboard and KPIs](docs/04-dashboard.md)
5. [Migration and troubleshooting](docs/05-migration-and-troubleshooting.md)
6. [Operations and security](docs/06-operations-and-security.md)
7. [Reproduction checklist](docs/07-reproduction-checklist.md)

**Scope:** This repository records the verified workflow and design. It does not yet include a tested one-command installer, the complete original SQL generator scripts, or a PostgreSQL dump. The original generator files reside on the Raspberry Pi at `/home/wynand/sa-enterprise-generator/`.

## Safety
Never commit passwords, Docker environment secrets, Metabase encryption keys, real customer information, or unreviewed database dumps. Do not publish the LAN dashboard to the internet without HTTPS and authentication.

## Project status
The dashboard was confirmed operational after Metabase metadata repairs and restored PostgreSQL SELECT permissions on 19 November 2026. Some charts required re-linking to active views after the data expansion.
