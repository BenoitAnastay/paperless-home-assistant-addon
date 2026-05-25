#!/command/with-contenv bashio
# shellcheck shell=bash
set -e

cd /usr/src/paperless/src || { bashio::log.error "Cannot change into /usr/src/paperless/src"; exit 1; }

BACKUP_PATH=$(bashio::config 'backup_path')
BACKUP_KEEP_COUNT=$(bashio::config 'backup_keep_count')

mkdir -p "${BACKUP_PATH}"

NOW=$(date '+%Y-%m-%d_%H-%M-%S')
bashio::log.info "Backup started: paperless-export-${NOW}.zip"

python3 manage.py document_exporter \
  "${BACKUP_PATH}" \
  --zip \
  --zip-name "paperless-export-${NOW}" \
  --no-progress-bar \
  || { bashio::log.error "Backup failed"; exit 1; }

bashio::log.info "Backup completed: ${BACKUP_PATH}/paperless-export-${NOW}.zip"

# Prune old backups beyond keep count
mapfile -t BACKUPS < <(ls -1t "${BACKUP_PATH}"/paperless-export-*.zip 2>/dev/null)
if [ "${#BACKUPS[@]}" -gt "${BACKUP_KEEP_COUNT}" ]; then
  for ((i=BACKUP_KEEP_COUNT; i<${#BACKUPS[@]}; i++)); do
    bashio::log.info "Removing old backup: ${BACKUPS[i]}"
    rm -f "${BACKUPS[i]}"
  done
fi
