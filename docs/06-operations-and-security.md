# 06 — Operations, backup and security

## Backup performed
Before the bulk expansion, a PostgreSQL custom-format backup was made at:

`/home/wynand/PostgreSQL-Backups/sa_enterprise_demo_20261119_090542.dump`

The original backup was about 44 KB and its archive listing was successfully read with `pg_restore -l`. It represents the **pre-expansion** database, not the 893,758-row result.

A schema export was also created:
`/home/wynand/sa_enterprise_schema.sql`

## Recommended post-expansion backup
Run on the Pi with adequate free space:

```bash
sudo -u postgres pg_dump -Fc -d sa_enterprise_demo -f /var/lib/postgresql/sa_enterprise_demo_post_expansion.dump
sudo -u postgres pg_restore -l /var/lib/postgresql/sa_enterprise_demo_post_expansion.dump >/dev/null
```

Choose a secure, backed-up destination and validate restore on a separate test database before relying on it.

## Maintenance
- Monitor disk capacity, memory and database growth on the Raspberry Pi.
- Run `ANALYZE` after bulk data loads.
- Keep PostgreSQL and Metabase patched.
- Back up both `sa_enterprise_demo` and `metabase_app`; the latter contains saved dashboards/questions.
- Use a dedicated read-only database account for Metabase.
- Restrict LAN and remote access; protect credentials.

## Repository hygiene
Never commit `.env` files, passwords, access tokens, personally identifiable information, or database dumps without explicit review. This public project is documentation for synthetic demonstration data only.
