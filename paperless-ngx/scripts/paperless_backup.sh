#!/bin/bash
set -e
set -o pipefail

mkdir -p /share/paperless/exports/temp

python3 manage.py document_exporter /share/paperless/exports/temp \
    || { echo "[ERROR] Creating export failed"; exit 1; }

cd /share/paperless/exports
zip -j "paperless-export-$(date +%F).zip" /share/paperless/exports/temp/* || { echo "[ERROR] Creating ZIP failed"; exit 1; }

rm -r /share/paperless/exports/temp || { echo "[ERROR] Deleting temp directory failed"; exit 1; }

echo "[INFO] Backup completed: paperless-export-$(date +%F).zip"