#!/command/with-contenv bashio
# shellcheck shell=bash
set -e

echo "[INFO] Configuring backup cron job..."

if type bashio >/dev/null 2>&1; then
    CRON_SCHEDULE="$(bashio::config 'backup_cron')"
    BACKUP_ENABLED="$(bashio::config 'backup_enabled')"
    BACKUP_KEEP_COUNT="$(bashio::config 'backup_keep_count')"
else
    CRON_SCHEDULE="0 2 * * *"
    BACKUP_ENABLED="false"
    BACKUP_KEEP_COUNT=-1
fi

if [ "$BACKUP_ENABLED" == "false" ]; then
    echo "[INFO] Backup cron job is disabled in configuration. Skipping setup."
    exit 0
fi

mkdir -p /etc/cron.d

echo "${CRON_SCHEDULE} /usr/local/bin/paperless_backup.sh" > /etc/cron.d/paperless-backup

chmod 0644 /etc/cron.d/paperless-backup

echo "[INFO] Backup cron job configured with schedule: $CRON_SCHEDULE & keep_count: $BACKUP_KEEP_COUNT"
