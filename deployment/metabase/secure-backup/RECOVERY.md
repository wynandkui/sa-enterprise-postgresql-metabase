# Recover the password-encrypted Metabase environment backup

This folder contains `metabase.env.age`, an **age passphrase-encrypted** backup of the original Raspberry Pi Metabase `/opt/metabase/.env`, created on 19 November 2026. The archive contains credentials and encryption/session keys. **Do not decrypt it into a public repository, shared folder, or Git commit.**

## Prerequisites

- `age` installed (`sudo apt-get install age` on Debian).
- The **separate passphrase** saved in KeePassXC under “Metabase GitHub Encrypted Backup”.
- Access to the encrypted archive in this repository.

## Decrypt into a private temporary file

On the machine where you need to restore the configuration:

```bash
umask 077
age --decrypt --output "$HOME/metabase.env.restored" metabase.env.age
chmod 600 "$HOME/metabase.env.restored"
```

Enter the passphrase interactively when prompted. Never include the passphrase in a command, script, Git commit, or chat message.

## Review before restoration

The recovered file contains **original test-system settings**, including the original database password, network settings, `MB_ENCRYPTION_SECRET_KEY` and `MB_SESSION_SECRET_KEY`. It is not automatically valid on a new host. If restoring the original Metabase application database, preserve the matching encryption key; replacing it with a new one may make stored encrypted settings unreadable.

Inspect privately (do not paste values into issues or logs):

```bash
chmod 600 "$HOME/metabase.env.restored"
```

If restoring to the **original** Raspberry Pi and you have confirmed this is the correct matching backup, first back up any existing environment file:

```bash
sudo cp -a /opt/metabase/.env "/opt/metabase/.env.pre-restore.$(date +%Y%m%d-%H%M%S)"
sudo install -o root -g root -m 600 "$HOME/metabase.env.restored" /opt/metabase/.env
```

**Do not run these restore commands on a working installation without deciding whether the old settings are appropriate.** The restore replaces the current configuration; it does not restore the PostgreSQL `metabase_app` database, analytics data, or Docker volumes. Container restart, if needed, is a separate planned action.

After a successful restoration, securely handle or remove the temporary plaintext copy; ordinary `rm` is not guaranteed secure erasure on flash storage.

## Security notes

- The repository is public. The encrypted file is visible to anyone; security depends on a **strong, unique passphrase** and keeping it secret.
- Store the passphrase outside GitHub, ideally in KeePassXC with its own independent backup.
- If the passphrase is lost, this backup cannot be decrypted. If it is exposed, rotate affected credentials and keys as appropriate.
- To recover the *complete* Metabase system, also preserve the `metabase_app` PostgreSQL database and the analytics database separately. This encrypted file only backs up environment settings.


## Restore the Metabase application database snapshot

The encrypted file `metabase_app_backup.dump.age` is a PostgreSQL **custom-format** backup of the Metabase application database, created on 19 November 2026. It holds saved questions, dashboards, collections, and other application metadata **as of that snapshot**. It does not contain the analytics database `sa_enterprise_demo`.

**Do not run database restore commands against a working Metabase installation.** First stop the Metabase container and back up the current `metabase_app` database. Restoring overwrites application state and can lose changes made after the snapshot. Use a separate recovery host or test database when possible.

### 1. Decrypt the snapshot locally

From the directory containing the downloaded encrypted file:

```bash
umask 077
age --decrypt --output "$HOME/metabase_app_backup.dump" metabase_app_backup.dump.age
chmod 600 "$HOME/metabase_app_backup.dump"
pg_restore --list "$HOME/metabase_app_backup.dump" | head -30
```

Enter the passphrase interactively. The `pg_restore --list` command reads the archive catalog only; it does not change any database.

### 2. Plan the database restore

On a **fresh recovery instance**, install a compatible PostgreSQL version, create the Metabase application role and a **new, empty** `metabase_app` database owned by that role, then restore the archive. Example for a deliberately empty database:

```bash
sudo -u postgres pg_restore \
  --dbname=metabase_app \
  --no-owner --no-acl \
  --exit-on-error \
  "$HOME/metabase_app_backup.dump"
```

**Important:** The `postgres` OS account may not be able to read a dump under your private home directory (mode 600). Stage the decrypted dump in a PostgreSQL-readable, tightly restricted location or invoke `pg_restore` using a suitably authorized account with file access. The command is an illustrative restore template, **not** a command to execute blindly on the original server. Do not use `--clean` or drop an existing database without a separate, confirmed recovery plan.

### 3. Restore the matching configuration

Follow the environment-file instructions above to decrypt `metabase.env.age`. Configure the restored Metabase instance to use the recovered `metabase_app` database and its **matching original** `MB_ENCRYPTION_SECRET_KEY`. Review the original database password, session key, host/port settings, and Metabase image version before starting the container. The original Compose uses `metabase/metabase:latest`; a future release may perform irreversible database migrations. Prefer a known-compatible, pinned Metabase version.

### 4. Validate and protect

After restoring into a **test instance**, confirm that dashboards, saved questions, and database connections work before using the recovered environment in production. Restore the analytics database separately if it is missing. Remove temporary plaintext dumps after recovery and keep the encrypted originals plus the KeePassXC passphrase backup in separate secure locations.

**Backup limitations:** Neither encrypted file is proof of a tested end-to-end restore. No restore test has been performed as part of this repository documentation.
