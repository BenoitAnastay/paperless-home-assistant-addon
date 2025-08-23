ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:7.8.3
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Add env
ENV TERM="xterm-256color"

# Paperless version
ARG PAPERLESS_VERSION="v2.18.2"

# Renovate packages

# renovate: datasource=repology depName=debian_12/gnupg2
ENV GNUPG_VERSION="2.2.40-1.1"

# renovate: datasource=repology depName=debian_12/postgresql
ENV POSTGRESQL_VERSION="15.10-0+deb12u1"

# renovate: datasource=repology depName=debian_12/zlib
ENV ZLIB_VERSION="1:1.2.13.dfsg-1"

# renovate: datasource=repology depName=debian_12/redis
ENV REDIS_VERSION="5:7.0.15-1~deb12u3"

# renovate: datasource=repology depName=debian_12/zbar
ENV LIBZBAR0_VERSION="0.23.92-7+deb12u1"

# Packages need for running
ARG RUNTIME_PACKAGES="\
  # General utils
  curl=7.88.1-10+deb12u12 \
  # Docker specific
  gosu=1.14-1+b10 \
  # Timezones support
  tzdata=2025b-0+deb12u1 \
  # fonts for text file thumbnail generation
  fonts-liberation=1:1.07.4-11 \
  gettext=0.21-12 \
  ghostscript=10.0.0~dfsg-11+deb12u7 \
  gnupg=${GNUPG_VERSION} \
  icc-profiles-free=2.0.1+dfsg-1.1 \
  imagemagick=8:6.9.11.60+dfsg-1.6+deb12u3 \
  # PostgreSQL
  libpq5=${POSTGRESQL_VERSION} \
  postgresql-client-15=${POSTGRESQL_VERSION} \
  # MySQL / MariaDB
  mariadb-client=1:10.11.11-0+deb12u1 \
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
  libxml2=2.9.14+dfsg-1.3~deb12u2 \
  libxslt1.1=1.1.35-1+deb12u1 \
  # itself
  qpdf=11.3.0-1+deb12u1 \
  # Mime type detection
  file=1:5.44-3 \
  libmagic1=1:5.44-3 \
  media-types=10.0.0 \
  zlib1g=${ZLIB_VERSION} \
  # Barcode splitter
  libzbar0=${LIBZBAR0_VERSION} \
  poppler-utils=22.12.0-2+deb12u1 \
  python3=3.11.2-1+b1 \
  python3-pip=23.0.1+dfsg-1 \
  python3-dev=3.11.2-1+b1 \
  python3-full=3.11.2-1+b1 \
  python3-magic=2:0.4.26-3 \
  wget \
  xz-utils=5.4.1-1 \
  redis-server=${REDIS_VERSION} \
  redis-tools=${REDIS_VERSION} \
  nginx=1.22.1-9+deb12u2"

# Buildx provided, must be defined to use though
ARG TARGETARCH

# Can be workflow provided, defaults set for manual building
ARG JBIG2ENC_VERSION=0.29
ARG QPDF_VERSION=11.9.0
ARG GS_VERSION=10.03.1
ARG ZXING_VERSION=2.3.0

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
  && apt-get install --yes --quiet --no-install-recommends ${RUNTIME_PACKAGES} \
  && echo "Installing pre-built updates" \
    && echo "Installing qpdf ${QPDF_VERSION}" \
      && curl --fail --silent --show-error --location \
        --output libqpdf29_${QPDF_VERSION}-1_${TARGETARCH}.deb \
        https://github.com/paperless-ngx/builder/releases/download/qpdf-${QPDF_VERSION}/libqpdf29_${QPDF_VERSION}-1_${TARGETARCH}.deb \
      && curl --fail --silent --show-error --location \
        --output qpdf_${QPDF_VERSION}-1_${TARGETARCH}.deb \
        https://github.com/paperless-ngx/builder/releases/download/qpdf-${QPDF_VERSION}/qpdf_${QPDF_VERSION}-1_${TARGETARCH}.deb \
      && dpkg --install ./libqpdf29_${QPDF_VERSION}-1_${TARGETARCH}.deb \
      && dpkg --install ./qpdf_${QPDF_VERSION}-1_${TARGETARCH}.deb \
    && echo "Installing Ghostscript ${GS_VERSION}" \
      && curl --fail --silent --show-error --location \
        --output libgs10_${GS_VERSION}.dfsg-1_${TARGETARCH}.deb \
        https://github.com/paperless-ngx/builder/releases/download/ghostscript-${GS_VERSION}/libgs10_${GS_VERSION}.dfsg-1_${TARGETARCH}.deb \
      && curl --fail --silent --show-error --location \
        --output ghostscript_${GS_VERSION}.dfsg-1_${TARGETARCH}.deb \
        https://github.com/paperless-ngx/builder/releases/download/ghostscript-${GS_VERSION}/ghostscript_${GS_VERSION}.dfsg-1_${TARGETARCH}.deb \
      && curl --fail --silent --show-error --location \
        --output libgs10-common_${GS_VERSION}.dfsg-1_all.deb \
        https://github.com/paperless-ngx/builder/releases/download/ghostscript-${GS_VERSION}/libgs10-common_${GS_VERSION}.dfsg-1_all.deb \
      && dpkg --install ./libgs10-common_${GS_VERSION}.dfsg-1_all.deb \
      && dpkg --install ./libgs10_${GS_VERSION}.dfsg-1_${TARGETARCH}.deb \
      && dpkg --install ./ghostscript_${GS_VERSION}.dfsg-1_${TARGETARCH}.deb \
      && echo "Installing jbig2enc" \
        && curl --fail --silent --show-error --location \
          --output jbig2enc_${JBIG2ENC_VERSION}-1_${TARGETARCH}.deb \
          https://github.com/paperless-ngx/builder/releases/download/jbig2enc-${JBIG2ENC_VERSION}/jbig2enc_${JBIG2ENC_VERSION}-1_${TARGETARCH}.deb \
        && dpkg --install ./jbig2enc_${JBIG2ENC_VERSION}-1_${TARGETARCH}.deb \
      && echo "Cleaning up image layer" \
        && rm --force --verbose *.deb \
    && rm --recursive --force --verbose /var/lib/apt/lists/* \
  && echo "Installing supervisor" \
  && rm /usr/lib/python3.11/EXTERNALLY-MANAGED \
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
  libpq-dev=${POSTGRESQL_VERSION} \
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
  && echo "Installing ZXing" \
  && curl --fail --silent --no-progress-meter --show-error --location --remote-name-all --parallel --parallel-max 4 \
      https://github.com/BenoitAnastay/paperless-builder/releases/download/v2.3.0/zxing_cpp-2.3.0-cp311-cp311-linux_aarch64.whl \
      https://github.com/BenoitAnastay/paperless-builder/releases/download/v2.3.0/zxing_cpp-2.3.0-cp311-cp311-linux_x86_64.whl \
  && uv pip install --system --find-links . zxing-cpp==${ZXING_VERSION} \
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
