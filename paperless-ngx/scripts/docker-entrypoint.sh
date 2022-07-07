
#!/bin/bash

set -e

CONFIG_PATH=/data/options.json

echo "Entry script"

./scripts/wait-for-redis.sh

# Load config
export PAPERLESS_URL=$(jq --raw-output ".url // ''" $CONFIG_PATH)
export PAPERLESS_FILENAME_FORMAT=$(jq --raw-output ".filename.format" $CONFIG_PATH)
export PAPERLESS_OCR_LANGUAGE=$(jq --raw-output ".ocr.language" $CONFIG_PATH)

export DEFAULT_USERNAME=$(jq --raw-output ".default_superuser.username" $CONFIG_PATH)
export DEFAULT_EMAIL=$(jq --raw-output ".default_superuser.email" $CONFIG_PATH)
export DEFAULT_PASSWORD=$(jq --raw-output ".default_superuser.password" $CONFIG_PATH)

# Change Paperless directories so that we can access the files
export PAPERLESS_CONSUMPTION_DIR=/share/paperless/consume
export PAPERLESS_DATA_DIR=/share/paperless/data
export PAPERLESS_MEDIA_ROOT=/share/paperless/media

mkdir -p $PAPERLESS_CONSUMPTION_DIR
mkdir -p $PAPERLESS_DATA_DIR
mkdir -p $PAPERLESS_MEDIA_ROOT

sudo chmod -R 777 /share/paperless


# Source: https://github.com/sameersbn/docker-gitlab/
map_uidgid() {
	USERMAP_ORIG_UID=$(id -u paperless)
	USERMAP_ORIG_GID=$(id -g paperless)
	USERMAP_NEW_UID=${USERMAP_UID:-$USERMAP_ORIG_UID}
	USERMAP_NEW_GID=${USERMAP_GID:-${USERMAP_ORIG_GID:-$USERMAP_NEW_UID}}
	if [[ ${USERMAP_NEW_UID} != "${USERMAP_ORIG_UID}" || ${USERMAP_NEW_GID} != "${USERMAP_ORIG_GID}" ]]; then
		echo "Mapping UID and GID for paperless:paperless to $USERMAP_NEW_UID:$USERMAP_NEW_GID"
		usermod -u "${USERMAP_NEW_UID}" paperless
		groupmod -o -g "${USERMAP_NEW_GID}" paperless
	fi
}

initialize() {
	map_uidgid

	for dir in export data data/index media media/documents media/documents/originals media/documents/thumbnails; do
		if [[ ! -d "../$dir" ]]; then
			echo "Creating directory ../$dir"
			mkdir ../$dir
		fi
	done

	echo "Creating directory /tmp/paperless"
	mkdir -p /tmp/paperless

	set +e
	echo "Adjusting permissions of paperless files. This may take a while."
	chown -R paperless:paperless /tmp/paperless
	find .. -not \( -user paperless -and -group paperless \) -exec chown paperless:paperless {} +
	set -e

	gosu paperless /sbin/docker-prepare.sh
}

install_languages() {
	echo "Installing languages..."

	local langs="$1"
	read -ra langs <<<"$langs"

	# Check that it is not empty
	if [ ${#langs[@]} -eq 0 ]; then
		return
	fi
	apt-get update

	for lang in "${langs[@]}"; do
		pkg="tesseract-ocr-$lang"
		# English is installed by default
		#if [[ "$lang" ==  "eng" ]]; then
		#    continue
		#fi

		if dpkg -s $pkg &>/dev/null; then
			echo "Package $pkg already installed!"
			continue
		fi

		if ! apt-cache show $pkg &>/dev/null; then
			echo "Package $pkg not found! :("
			continue
		fi

		echo "Installing package $pkg..."
		if ! apt-get -y install "$pkg" &>/dev/null; then
			echo "Could not install $pkg"
			exit 1
		fi
	done
}

echo "Paperless-ngx docker container starting..."

# Install additional languages if specified
if [[ ! -z "$PAPERLESS_OCR_LANGUAGES" ]]; then
	install_languages "$PAPERLESS_OCR_LANGUAGES"
fi

initialize

cat scripts/setup_superuser.py | python3 manage.py shell


if [[ "$1" != "/"* ]]; then
	echo Executing management command "$@"
	exec gosu paperless python3 manage.py "$@"
else
	echo Executing "$@"
	exec "$@"
fi