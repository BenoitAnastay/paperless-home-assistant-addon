#!/command/with-contenv bashio
# shellcheck shell=bash
set -e

echo "[INFO] Configuring backup cron job..."

# HA Add-on Config auslesen
if type bashio >/dev/null 2>&1; then
    CRON_SCHEDULE="$(bashio::config 'backup_cron')"
else
    CRON_SCHEDULE="${BACKUP_CRON:-0 2 * * *}"
fi

# Cron-Verzeichnis existiert sicherstellen
mkdir -p /etc/cron.d
mkdir -p /share/paperless/exports

# Cron-Job Datei erstellen
echo "${CRON_SCHEDULE:-0 3 * * *} /usr/local/bin/paperless_backup.sh" > /etc/cron.d/paperless-backup

chmod 0644 /etc/cron.d/paperless-backup

echo "[INFO] Backup cron job configured with schedule: $CRON_SCHEDULE"
