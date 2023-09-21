#!/usr/bin/env bash
# shellcheck disable=SC2086

# Replace env 

set -eu

PAPERLESS_URL=$(jq --raw-output ".url // empty" $CONFIG_PATH)
PAPERLESS_FILENAME_FORMAT=$(jq --raw-output ".filename.format" $CONFIG_PATH)
PAPERLESS_OCR_LANGUAGE=$(jq --raw-output ".ocr.language" $CONFIG_PATH)
DEFAULT_USERNAME=$(jq --raw-output ".default_superuser.username" $CONFIG_PATH)
DEFAULT_EMAIL=$(jq --raw-output ".default_superuser.email" $CONFIG_PATH)
DEFAULT_PASSWORD=$(jq --raw-output ".default_superuser.password" $CONFIG_PATH)
PAPERLESS_TIME_ZONE=$(jq --raw-output ".timezone.timezone" $CONFIG_PATH)
PAPERLESS_CONSUMPTION_DIR=/share/paperless/consume
PAPERLESS_DATA_DIR=/share/paperless/data
PAPERLESS_MEDIA_ROOT=/share/paperless/media

export PAPERLESS_URL
export PAPERLESS_FILENAME_FORMAT
export PAPERLESS_OCR_LANGUAGE
export DEFAULT_USERNAME
export DEFAULT_EMAIL
export DEFAULT_PASSWORD
export PAPERLESS_TIME_ZONE
export PAPERLESS_CONSUMPTION_DIR
export PAPERLESS_DATA_DIR
export PAPERLESS_MEDIA_ROOT