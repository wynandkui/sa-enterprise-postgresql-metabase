# Metabase Docker Compose — sanitized deployment reference

This directory documents the **existing** Raspberry Pi 4 deployment as reported on 19 November 2026. It is a reference, **not a tested turnkey installer**.

## Files

- `compose.yaml`: working service configuration with `metabase/metabase:latest`, host networking, `restart: unless-stopped`, `mem_limit: 1536m`, and `no-new-privileges:true`.
- `.env.example`: illustrative variable names and placeholder values, **not** a copy of production secrets.

## Deployment considerations

1. Install Docker Engine and Compose, and prepare PostgreSQL 17 and a separate `metabase_app` database.
2. Copy `.env.example` to `.env` and set valid credentials and fresh random secrets. Review `JAVA_TOOL_OPTIONS` for the host's memory constraints; the placeholder is not executable JVM tuning.
3. The Compose file uses `network_mode: host`: Metabase binds directly on the host. The original installation used port `3001` and PostgreSQL on `127.0.0.1:5432`; these addresses may differ elsewhere.
4. From this directory, run `docker compose up -d` only after reviewing and completing the environment settings.
5. Configure the **analytics** database `sa_enterprise_demo` in Metabase separately, using a restricted read-only account. Metabase's **application** database `metabase_app` is not the analytics source.
6. Protect `.env` (e.g. `chmod 600 .env`) and exclude it from Git. Never commit production keys or database dumps.

## Versioning and security

The original configuration uses `metabase/metabase:latest`, which is **not pinned** and can change on future pulls. Pin a tested release or digest before attempting reproducible redeployment. Do not publish the host-network Metabase port directly to the public internet. Restrict access and use an authenticated HTTPS reverse proxy if remote access is required.

## Existing installation warning

Do **not** replace the running `/opt/metabase/.env` with this example: it contains placeholders. In particular, changing `MB_ENCRYPTION_SECRET_KEY` on an established installation can make previously encrypted credentials unreadable. This repository does not contain or reconstruct the production keys.
