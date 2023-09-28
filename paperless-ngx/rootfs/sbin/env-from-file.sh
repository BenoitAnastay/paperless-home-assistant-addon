#!/usr/bin/env bashio
# shellcheck disable=SC2086

#start redis
redis-server --daemonize yes

# Replace env 
PAPERLESS_URL="http://"+$(bashio::info.hostname)+":8000"
PAPERLESS_FILENAME_FORMAT=$(bashio::config 'filename')
PAPERLESS_OCR_LANGUAGE=$(bashio::config 'language')
DEFAULT_USERNAME=$(bashio::config 'default_superuser.usename')
DEFAULT_EMAIL=$(bashio::config 'default_superuser.email')
DEFAULT_PASSWORD=$(bashio::config 'default_superuser.password')
PAPERLESS_TIME_ZONE=$(bashio::info.timezone)
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