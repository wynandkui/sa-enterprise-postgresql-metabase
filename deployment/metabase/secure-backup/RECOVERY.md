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
