#!/command/with-contenv bashio
# shellcheck shell=bash
set -e

if type bashio >/dev/null 2>&1; then
    BACKUP_KEEP_COUNT="$(bashio::config 'backup_keep_count')"
    BACKUP_PATH="$(bashio::config 'backup_path')"
else
    BACKUP_KEEP_COUNT=3
    BACKUP_PATH="/share/paperless/exports"
fi

NOW=$(date '+%Y-%m-%d-%H:%M:%S')
echo "[INFO] Backup started: $NOW"

python3 manage.py document_exporter \
  "$BACKUP_PATH" \
  -z \
  -zn "paperless-export-$NOW" \
  || { echo "[ERROR] Creating export failed"; exit 1; }

echo "[INFO] Backup completed: paperless-export-$NOW.zip"

# -----------------------------
# Delete old backups
# -----------------------------
BACKUP_DIR="$BACKUP_PATH"

mapfile -t BACKUPS < <(ls -1t "$BACKUP_DIR"/paperless-export-*.zip 2>/dev/null)

if [ "${#BACKUPS[@]}" -gt "$BACKUP_KEEP_COUNT" ]; then
    for ((i=BACKUP_KEEP_COUNT; i<${#BACKUPS[@]}; i++)); do
        echo "[INFO] Deleting old backup: ${BACKUPS[i]}"
        rm -f "${BACKUPS[i]}"
    done
fi