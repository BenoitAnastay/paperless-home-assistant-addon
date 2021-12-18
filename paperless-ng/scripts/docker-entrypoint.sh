
#!/bin/bash

set -e

CONFIG_PATH=/data/options.json

echo "Entry script"

./scripts/wait-for-redis.sh

# Load config
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


wait_for_postgres() {
	attempt_num=1
	max_attempts=5

	echo "Waiting for PostgreSQL to start..."

	host="${PAPERLESS_DBHOST}"
	port="${PAPERLESS_DBPORT}"

	if [[ -z $port ]] ;
	then
		port="5432"
	fi

	while !</dev/tcp/$host/$port ;
	do

		if [ $attempt_num -eq $max_attempts ]
		then
			echo "Unable to connect to database."
			exit 1
		else
			echo "Attempt $attempt_num failed! Trying again in 5 seconds..."

		fi

		attempt_num=$(expr "$attempt_num" + 1)
		sleep 5
	done


}


migrations() {

	if [[ -n "${PAPERLESS_DBHOST}" ]]
	then
		wait_for_postgres
	fi

	(
		# flock is in place to prevent multiple containers from doing migrations
		# simultaneously. This also ensures that the db is ready when the command
		# of the current container starts.
		flock 200
		sudo -HEu paperless python3 manage.py migrate
	)  200>/usr/src/paperless/data/migration_lock

}

search_index() {
	index_version=1
	index_version_file=/usr/src/paperless/data/.index_version

	if [[ (! -f "$index_version_file") || $(< $index_version_file) != "$index_version" ]]; then
		echo "Search index out of date. Updating..."
		sudo -HEu paperless python3 manage.py document_index reindex
		echo $index_version | sudo -HEu paperless tee $index_version_file >/dev/null
	fi
}

initialize() {
	map_uidgid

	for dir in export data data/index media media/documents media/documents/originals media/documents/thumbnails; do
		if [[ ! -d "../$dir" ]]
		then
			echo "creating directory ../$dir"
			mkdir ../$dir
		fi
	done

	chown -R paperless:paperless ../

	migrations

	search_index
}

install_languages() {
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

        if dpkg -s $pkg &> /dev/null; then
        	echo "package $pkg already installed!"
        	continue
        fi

        if ! apt-cache show $pkg &> /dev/null; then
        	echo "package $pkg not found! :("
        	continue
        fi

				echo "Installing package $pkg..."
				if ! apt-get -y install "$pkg" &> /dev/null; then
					echo "Could not install $pkg"
					exit 1
				fi
    done
}

# Install additional languages if specified
if [[ ! -z "$PAPERLESS_OCR_LANGUAGES"  ]]; then
		install_languages "$PAPERLESS_OCR_LANGUAGES"
fi

initialize

# echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@myproject.com', 'password')" | python3 manage.py shell
cat scripts/setup_superuser.py | python3 manage.py shell


if [[ "$1" != "/"* ]]; then
	exec sudo -HEu paperless python3 manage.py "$@"
else
	exec "$@"
fi