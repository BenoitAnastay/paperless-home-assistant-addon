ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:9.1.0
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Add env
ENV TERM="xterm-256color"

# Paperless version
ARG PAPERLESS_VERSION="v2.20.0"

# Renovate packages

# renovate: datasource=repology depName=debian_13/gnupg2
ENV GNUPG_VERSION="2.4.7-21"

# renovate: datasource=repology depName=debian_13/postgresql
ENV POSTGRESQL_VERSION="17+278"

# renovate: datasource=repology depName=debian_13/zlib
ENV ZLIB_VERSION="1:1.3.dfsg+really1.3.1-1+b1"

# renovate: datasource=repology depName=debian_13/redis
ENV REDIS_VERSION="5:8.0.2-3"

# renovate: datasource=repology depName=debian_13/zbar
ENV LIBZBAR0_VERSION="0.23.93-8"

# renovate: datasource=repology depName=debian_13/ghostscript
ENV GHOSTSCRIPT_VERSION="10.05.1~dfsg-1"

ENV UNPAPER_X64_VERSION="7.0.0-3+b2"
ENV UNPAPER_ARM_VERSION="7.0.0-3+b3"

ENV PNGQUANT_X64_VERSION="2.18.0-1+b1"
ENV PNGQUANT_ARM_VERSION="2.18.0-1+b2"

# Packages need for running
ARG RUNTIME_PACKAGES="\
  # General utils
  curl=8.14.1-2 \
  # Docker specific
  gosu=1.17-3+b4 \
  # Timezones support
  tzdata=2025b-4+deb13u1 \
  # fonts for text file thumbnail generation
  fonts-liberation=1:2.1.5-3 \
  gettext=0.23.1-2 \
  ghostscript=10.05.1~dfsg-1+deb13u1 \
  gnupg=${GNUPG_VERSION} \
  icc-profiles-free=2.0.1+dfsg-1.1 \
  imagemagick=8:7.1.1.43+dfsg1-1+deb13u3 \
  # PostgreSQL
  libpq5=17.6-0+deb13u1 \
  postgresql-client=${POSTGRESQL_VERSION} \
  # MySQL / MariaDB
  mariadb-client=1:11.8.3-0+deb13u1 \
  # OCRmyPDF dependencies
  tesseract-ocr=5.5.0-1+b1 \
  tesseract-ocr-eng=1:4.1.0-2 \
  tesseract-ocr-deu=1:4.1.0-2 \
  tesseract-ocr-fra=1:4.1.0-2 \
  tesseract-ocr-ita=1:4.1.0-2 \
  tesseract-ocr-spa=1:4.1.0-2 \
  jbig2dec=0.20-1+b3 \
  # lxml
  libxml2=2.12.7+dfsg+really2.9.14-2.1+deb13u2 \
  libxslt1.1=1.1.35-1.2+deb13u1 \
  # itself
  qpdf=12.2.0-1 \
  # Mime type detection
  file=1:5.46-5 \
  libmagic1t64=1:5.46-5 \
  media-types=13.0.0 \
  zlib1g=${ZLIB_VERSION} \
  # Barcode splitter
  libzbar0t64=${LIBZBAR0_VERSION} \
  poppler-utils=25.03.0-5+deb13u2 \
  python3=3.13.5-1 \
  python3-pip=25.1.1+dfsg-1 \
  python3-dev=3.13.5-1 \
  python3-full=3.13.5-1 \
  python3-magic=2:0.4.27-3 \
  python3-zxing-cpp=2.3.0-4 \
  wget=1.25.0-2 \
  xz-utils=5.8.1-1 \
  redis-server=${REDIS_VERSION} \
  redis-tools=${REDIS_VERSION} \
  nginx=1.26.3-3+deb13u1 \
  # ghostscript
  libgs10=${GHOSTSCRIPT_VERSION} \
  libgs10-common=${GHOSTSCRIPT_VERSION} \
  ghostscript=${GHOSTSCRIPT_VERSION} \
  libjbig2enc-dev=0.30-1 \
  qpdf=12.2.0-1"

# Buildx provided, must be defined to use though
ARG TARGETARCH

# Set Python environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    # Ignore warning from Whitenoise
    PYTHONWARNINGS="ignore:::django.http.response:517" \
    PNGX_CONTAINERIZED=1

# Install basic runtime packages.
# These change very infrequently
# hadolint ignore=DL3003,DL3042,DL3008,SC2086
RUN --mount=type=cache,target=/root/.cache/uv/,id=uv-cache \
  set -eux \
  echo "Installing system packages" \
  && apt-get update \
  && echo "Installing unpaper for ${TARGETARCH}" \
  && case "${TARGETARCH}" in \
         "amd64")  apt-get install --yes --quiet --no-install-recommends unpaper=${UNPAPER_X64_VERSION} pngquant=${PNGQUANT_X64_VERSION} ;; \
         "arm64")  apt-get install --yes --quiet --no-install-recommends unpaper=${UNPAPER_ARM_VERSION} pngquant=${PNGQUANT_ARM_VERSION} ;; \
         *) exit 1 ;; \
    esac \
  && apt-get install --yes --quiet --no-install-recommends ${RUNTIME_PACKAGES} \
  && echo "Installing supervisor" \
  && rm /usr/lib/python3.13/EXTERNALLY-MANAGED \
  && curl -LsSf https://astral.sh/uv/install.sh | sh \
  && source $HOME/.local/bin/env \
  && uv pip install --system --upgrade --no-cache-dir supervisor==4.2.5 \
  && echo "Download Paperless-ngx" \
  && curl -J -L -s -o paperless.tar.xz https://github.com/paperless-ngx/paperless-ngx/releases/download/${PAPERLESS_VERSION}/paperless-ngx-${PAPERLESS_VERSION}.tar.xz \
  && tar -xf paperless.tar.xz \
  && mv paperless-ngx /usr/src/paperless

WORKDIR /usr/src/paperless

# Packages needed only for building a few quick Python
# dependencies
ARG BUILD_PACKAGES="\
  build-essential \
  git \
  # https://www.psycopg.org/docs/install.html#prerequisites
  libpq-dev=17.6-0+deb13u1 \
  # https://github.com/PyMySQL/mysqlclient#linux
  default-libmysqlclient-dev \
  pkg-config"

# Install requirements
# hadolint ignore=DL3042,DL3008,DL3013,SC2086
RUN --mount=type=cache,target=/root/.cache/uv/,id=uv-cache \
  set -eux \
  && echo "Installing build system packages" \
  && apt-get update \
  && apt-get install --yes --quiet --no-install-recommends ${BUILD_PACKAGES} \
  && source $HOME/.local/bin/env \
  && uv pip install --system --no-cache-dir --upgrade wheel \
  && echo "Installing Python requirements" \
  && uv pip install --system --find-links . --requirement requirements.txt \
  && echo "Installing NLTK data" \
  && python3 -W ignore::RuntimeWarning -m nltk.downloader -d "/usr/share/nltk_data" snowball_data \
  && python3 -W ignore::RuntimeWarning -m nltk.downloader -d "/usr/share/nltk_data" stopwords \
  && python3 -W ignore::RuntimeWarning -m nltk.downloader -d "/usr/share/nltk_data" punkt_tab \
  && echo "Cleaning up image" \
  && apt-get -y purge ${BUILD_PACKAGES} \
  && apt-get -y autoremove --purge \
  && apt-get clean --yes \
  && rm -rf *.whl \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && rm -rf /var/tmp/* \
  && rm -rf /var/cache/apt/archives/

WORKDIR /usr/src/paperless/docker/

RUN set -eux \
  && cp -r /usr/src/paperless/docker/rootfs/* / \
  && echo "Configuring ImageMagick" \
  && cp /etc/ImageMagick-6/paperless-policy.xml /etc/ImageMagick-6/policy.xml

WORKDIR /usr/src/paperless/src/

# add users, setup scripts
# Mount the compiled frontend to expected location
RUN set -eux \
 && echo "Creating gnupg directory" \
    && mkdir -m700 --verbose /usr/src/paperless/.gnupg \
  && addgroup --gid 1000 paperless \
  && useradd --uid 1000 --gid paperless --home-dir /usr/src/paperless paperless \
  && chown -R paperless:paperless /usr/src/paperless \
  && gosu paperless python3 manage.py collectstatic --clear --no-input --link \
  && gosu paperless python3 manage.py compilemessages

ENV PAPERLESS_REDIS="redis://localhost:6379"
ENV PAPERLESS_DATA_DIR="/config/data"
ENV PAPERLESS_MEDIA_ROOT="/share/paperless/media"
ENV PAPERLESS_CONFIGURATION_PATH="/config/paperless.conf"
RUN sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf

VOLUME ["/usr/src/paperless/data", \
  "/usr/src/paperless/media", \
  "/usr/src/paperless/consume", \
  "/usr/src/paperless/export"]

# Copy root filesystem
COPY rootfs/ /

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
  maintainer="Benoit Anastay <benoit@anastay.dev>" \
  org.opencontainers.image.title="${BUILD_NAME}" \
  org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
  org.opencontainers.image.vendor="Benoit Anastay Add-on" \
  org.opencontainers.image.authors="Benoit Anastay <benoit@anastay.dev>" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.url="https://github.com/paperless-ngx/paperless-ngx" \
  org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
  org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
  org.opencontainers.image.created=${BUILD_DATE} \
  org.opencontainers.image.revision=${BUILD_REF} \
  org.opencontainers.image.version=${BUILD_VERSION}
