#!/command/with-contenv bashio
# shellcheck shell=bash
set -e

echo "[INFO] Configuring backup cron job..."

if bashio::config.has_value 'backup_enabled'; then
    BACKUP_ENABLED="$(bashio::config 'backup_enabled')"
else
    BACKUP_ENABLED="false"
fi

if bashio::config.has_value 'backup_cron'; then
    CRON_SCHEDULE="$(bashio::config 'backup_cron')"
else
    CRON_SCHEDULE="0 2 * * *"
fi

if [ "$BACKUP_ENABLED" == "false" ]; then
    echo "[INFO] Backup cron job is disabled in configuration. Skipping setup."
    exit 0
fi

mkdir -p /etc/cron.d

echo "${CRON_SCHEDULE} /usr/local/bin/paperless_backup.sh" > /etc/cron.d/paperless-backup

chmod 0644 /etc/cron.d/paperless-backup

echo "[INFO] Backup cron job configured with schedule: $CRON_SCHEDULE"
