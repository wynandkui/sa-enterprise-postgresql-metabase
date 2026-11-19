# 03 — Metabase integration

## Deployment
Metabase ran in Docker on the Raspberry Pi, exposed on LAN port **3001**. Its application metadata was stored in PostgreSQL database `metabase_app`; the analytics connection pointed to `sa_enterprise_demo`.

Open `http://<raspberry-pi-ip>:3001` from a LAN browser. The original host address was `192.168.0.188`.

## Database connection
In Metabase Admin > Databases, configure PostgreSQL with the correct host, port 5432, database `sa_enterprise_demo`, and a dedicated reader account. Do not use the PostgreSQL superuser for dashboards. The connection's exact host name depends on whether the container uses host networking.

## Permissions
The database reader needs CONNECT, USAGE on `public`, and SELECT on the reporting views and any tables referenced by native SQL questions. Future views should be covered by appropriate default privileges, but default privileges apply only to objects created by the specified owning role.

Example — **review and adapt to your deployment**:

```sql
GRANT CONNECT ON DATABASE sa_enterprise_demo TO metabase_reader;
GRANT USAGE ON SCHEMA public TO metabase_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO metabase_reader;
```

For tighter least privilege, grant SELECT only on the required reporting views and referenced tables.

## Metadata synchronization
When a view exists in PostgreSQL but Metabase says it is inactive, use Admin > Databases > South African Enterprise Demo > Sync database schema now. Verify that saved questions point to active view metadata; syncing does not necessarily repair questions referencing retired metadata IDs.

## Security
Keep passwords in a protected environment or secret store, never in GitHub. Metabase HTTP should remain on the trusted LAN unless protected by a properly configured HTTPS reverse proxy and access controls.
