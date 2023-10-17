ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:7.1.0
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Add env
ENV TERM="xterm-256color"

# Setup base
ARG version=v1.17.4

# Packages need for running
ARG RUNTIME_PACKAGES="\
  # General utils
  curl=7.88.1-10+deb12u4 \
  # Docker specific
  gosu=1.14-1+b6 \
  # Timezones support
  tzdata=2023c-5 \
  # fonts for text file thumbnail generation
  fonts-liberation=1:1.07.4-11 \
  gettext=0.21-12 \
  ghostscript=10.0.0~dfsg-11+deb12u1 \
  gnupg=2.2.40-1.1 \
  icc-profiles-free=2.0.1+dfsg-1.1 \
  imagemagick=8:6.9.11.60+dfsg-1.6 \
  # PostgreSQL
  libpq5=15.3-0+deb12u1 \
  postgresql-client=15+248 \
  # MySQL / MariaDB
  mariadb-client=1:10.11.3-1 \
  # OCRmyPDF dependencies
  tesseract-ocr=5.3.0-2 \
  tesseract-ocr-eng=1:4.1.0-2 \
  tesseract-ocr-deu=1:4.1.0-2 \
  tesseract-ocr-fra=1:4.1.0-2 \
  tesseract-ocr-ita=1:4.1.0-2 \
  tesseract-ocr-spa=1:4.1.0-2 \
  unpaper=7.0.0-0.1 \
  pngquant=2.17.0-1 \
  jbig2dec=0.19-3 \
  # lxml
  libxml2=2.9.14+dfsg-1.3~deb12u1 \
  libxslt1.1=1.1.35-1 \
  # itself
  qpdf=11.3.0-1 \
  # Mime type detection
  file=1:5.44-3 \
  libmagic1=1:5.44-3 \
  media-types=10.0.0 \
  zlib1g=1:1.2.13.dfsg-1 \
  # Barcode splitter
  libzbar0=0.23.92-7 \
  poppler-utils=22.12.0-2+b1 \
  python3=3.11.2-1+b1 \
  python3-pip=23.0.1+dfsg-1 \
  python3-dev=3.11.2-1+b1 \
  python3-full=3.11.2-1+b1 \
  wget \
  xz-utils=5.4.1-0.2 \
  redis-server=5:7.0.11-1 \
  redis-tools=5:7.0.11-1"

# Install basic runtime packages.
# These change very infrequently
# hadolint ignore=DL3003,DL3042,DL3008
RUN set -eux \
  echo "Installing system packages" \
    && apt-get update \
    && apt-get install --yes --quiet --no-install-recommends ${RUNTIME_PACKAGES} \
    && rm -rf /var/lib/apt/lists/* \
  && echo "Installing supervisor" \
    && rm /usr/lib/python3.11/EXTERNALLY-MANAGED \
    && python3 -m pip install --default-timeout=1000 --upgrade --no-cache-dir supervisor==4.2.5 \
  && echo "Download Paperless-ngx" \
    && wget -q -O paperless.tar.xz https://github.com/BenoitAnastay/paperless-ngx/releases/download/v1.17.4/paperless-ngx-v1.17.4.tar.xz \
    && tar -xf paperless.tar.xz \
    && mv paperless-ngx /usr/src/paperless

WORKDIR /usr/src/paperless

# Packages needed only for building a few quick Python
# dependencies
ARG BUILD_PACKAGES="\
  build-essential \
  git \
  # https://www.psycopg.org/docs/install.html#prerequisites
  libpq-dev \
  # https://github.com/PyMySQL/mysqlclient#linux
  default-libmysqlclient-dev \
  pkg-config"

# Install requirements
# hadolint ignore=DL3042,DL3008,DL3013
RUN --mount=type=cache,target=/root/.cache/pip/,id=pip-cache \
  set -eux \
  && echo "Installing build system packages" \
    && apt-get update \
    && apt-get install --yes --quiet --no-install-recommends ${BUILD_PACKAGES} \
    && python3 -m pip install --no-cache-dir --upgrade wheel \
  && echo "Installing Python requirements" \
    && python3 -m pip install --default-timeout=1000 --requirement requirements.txt \
  && echo "Installing NLTK data" \
    && python3 -W ignore::RuntimeWarning -m nltk.downloader -d "/usr/share/nltk_data" snowball_data \
    && python3 -W ignore::RuntimeWarning -m nltk.downloader -d "/usr/share/nltk_data" stopwords \
    && python3 -W ignore::RuntimeWarning -m nltk.downloader -d "/usr/share/nltk_data" punkt \
  && echo "Cleaning up image" \
    && apt-get -y purge ${BUILD_PACKAGES} \
    && apt-get -y autoremove --purge \
    && apt-get clean --yes \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf /var/cache/apt/archives/

WORKDIR /usr/src/paperless/docker/

RUN set -eux \
  && echo "Configuring ImageMagick" \
    && mv imagemagick-policy.xml /etc/ImageMagick-6/policy.xml \
  && echo "Configuring supervisord" \
    && mkdir /var/log/supervisord /var/run/supervisord \
    && mv supervisord.conf /etc/supervisord.conf \
  && echo "Setting up Docker scripts" \
    && mv docker-entrypoint.sh /sbin/docker-entrypoint.sh \
    && chmod 755 /sbin/docker-entrypoint.sh \
    && mv docker-prepare.sh /sbin/docker-prepare.sh \
    && chmod 755 /sbin/docker-prepare.sh \
    && mv wait-for-redis.py /sbin/wait-for-redis.py \
    && chmod 755 /sbin/wait-for-redis.py \
    && mv env-from-file.sh /sbin/env-from-file.sh \
    && chmod 755 /sbin/env-from-file.sh \
    && mv paperless_cmd.sh /usr/local/bin/paperless_cmd.sh \
    && chmod 755 /usr/local/bin/paperless_cmd.sh \
    && mv flower-conditional.sh /usr/local/bin/flower-conditional.sh \
    && chmod 755 /usr/local/bin/flower-conditional.sh \
  && echo "Installing managment commands" \
    && chmod +x install_management_commands.sh \
    && ./install_management_commands.sh

WORKDIR /usr/src/paperless/src/

# add users, setup scripts
# Mount the compiled frontend to expected location
RUN set -eux \
  && addgroup --gid 1000 paperless \
  && useradd --uid 1000 --gid paperless --home-dir /usr/src/paperless paperless \
  && chown -R paperless:paperless /usr/src/paperless \
  && gosu paperless python3 manage.py collectstatic --clear --no-input --link \
  && gosu paperless python3 manage.py compilemessages

ENV PAPERLESS_REDIS="redis://localhost:6379"
RUN sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf

VOLUME ["/usr/src/paperless/data", \
        "/usr/src/paperless/media", \
        "/usr/src/paperless/consume", \
        "/usr/src/paperless/export"]

# Copy root filesystem
COPY rootfs/run.sh /run.sh

RUN chmod 755 /run.sh 

ENTRYPOINT ["/run.sh"]

EXPOSE 8000

CMD ["/usr/local/bin/paperless_cmd.sh"]

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Benoit Anastay <45088785+BenoitAnastay@users.noreply.github.com>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Benoit Anastay Custom Addon" \
    org.opencontainers.image.authors="Benoit Anastay <45088785+BenoitAnastay@users.noreply.github.com>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/paperless-ngx/paperless-ngx" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
