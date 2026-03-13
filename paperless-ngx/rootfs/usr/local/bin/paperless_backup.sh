#!/command/with-contenv bashio
# shellcheck shell=bash
set -e

cd /usr/src/paperless/src || { echo "[ERROR] Cannot change into /usr/src/paperless/src"; exit 1; }

if bashio::config.has_value 'backup_path'; then
    BACKUP_PATH="$(bashio::config 'backup_path')"
else
    echo "[ERROR] No backup path configured. Please set 'backup_path' in the add-on configuration."
    exit 1
fi

if bashio::config.has_value 'backup_keep_count'; then
    BACKUP_KEEP_COUNT="$(bashio::config 'backup_keep_count')"
else
    echo "[WARN] 'backup_keep_count' not set, defaulting to 3"
    BACKUP_KEEP_COUNT=3
fi

NOW=$(date '+%Y-%m-%d-%H:%M:%S')
echo "[INFO] Backup started: $NOW"

mkdir -p "$BACKUP_PATH"

python3 manage.py document_exporter \
  "$BACKUP_PATH" \
  -z \
  -zn "paperless-export-$NOW" \
  --no-progress-bar \
  || { echo "[ERROR] Creating export failed"; exit 1; }

echo "[INFO] Backup completed: $BACKUP_PATH/paperless-export-$NOW.zip"

# -----------------------------
# Delete old backups
# -----------------------------
mapfile -t BACKUPS < <(ls -1t "$BACKUP_PATH"/paperless-export-*.zip 2>/dev/null)

if [ "${#BACKUPS[@]}" -gt "$BACKUP_KEEP_COUNT" ]; then
    for ((i=BACKUP_KEEP_COUNT; i<${#BACKUPS[@]}; i++)); do
        echo "[INFO] Deleting old backup: ${BACKUPS[i]}"
        rm -f "${BACKUPS[i]}"
    done
fi