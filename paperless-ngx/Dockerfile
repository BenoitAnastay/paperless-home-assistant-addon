ARG BUILD_FROM=ghcr.io/hassio-addons/base:14.1.0
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Add env
ENV TERM="xterm-256color"

# Setup base
ARG version=v1.17.4

# hadolint ignore=DL3003,DL3042,DL3018
RUN set -eux \
  echo "Installing system packages" \
    && apk add --no-cache \
        gcc \
        g++ \
        gfortran \
        musl \
        musl-dev \
        openblas-dev \
        make \
        python3 \
        py3-pip \
        python3-dev \
        openblas \
        ttf-liberation \
        imagemagick \
        gnupg \
        file \
        mailcap \
        libmagic \
        libzbar \
        poppler-utils \
        shared-mime-info \
        unpaper \
        ghostscript \
        libxml2 \
        libxslt \
        libxml2-dev \
        libxslt-dev \
        pngquant \
        zlib \
        tesseract-ocr \
        tesseract-ocr-data-fra \
        tesseract-ocr-data-deu \
        tesseract-ocr-data-ita \
        tesseract-ocr-data-spa \
        ocrmypdf \
        redis \
        supervisor \
        mariadb-dev \
        mariadb-connector-c-dev \
        mariadb-connector-c \
        freetype-dev \
        libpq-dev \
        qpdf-dev \
        qpdf \
        gettext \
        linux-headers \
    && echo "Installing supervisor" \
        && python3 -m pip install --default-timeout=1000 --upgrade --no-cache-dir supervisor==4.2.5

RUN mkdir /usr/src \
    && wget -q -O paperless.tar.xz https://github.com/BenoitAnastay/paperless-ngx/releases/download/v1.17.4/paperless-ngx-v1.17.4.tar.xz \
    && tar -xf paperless.tar.xz \
    && mv paperless-ngx /usr/src/paperless

WORKDIR /usr/src/paperless

# Install requirements
# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir --upgrade wheel \
    && echo "Installing Python requirements" \
    && pip3 install --no-cache-dir --default-timeout=1000 --requirement requirements.txt \
    && echo "Installing NLTK data" \
    && python3 -W ignore::RuntimeWarning -m nltk.downloader -d "/usr/share/nltk_data" snowball_data \
    && python3 -W ignore::RuntimeWarning -m nltk.downloader -d "/usr/share/nltk_data" stopwords \
    && python3 -W ignore::RuntimeWarning -m nltk.downloader -d "/usr/share/nltk_data" punkt

WORKDIR /usr/src/paperless/docker/

COPY [ \
  "docker/imagemagick-policy.xml", \
  "docker/supervisord.conf", \
  "docker/docker-entrypoint.sh", \
  "docker/docker-prepare.sh", \
  "docker/paperless_cmd.sh", \
  "docker/wait-for-redis.py", \
  "docker/env-from-file.sh", \
  "docker/management_script.sh", \
  "docker/flower-conditional.sh", \
  "docker/install_management_commands.sh", \
  "/usr/src/paperless/src/docker/" \
]

RUN set -eux \
  && echo "Configuring ImageMagick" \
    && mv imagemagick-policy.xml /etc/ImageMagick-7/policy.xml \
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

RUN set -eux \
  && addgroup --gid 1000 paperless \
  && adduser -D -u 1000 -G paperless -h /usr/src/paperless/ paperless \
  && chown -R paperless:paperless /usr/src/paperless/ \
  && su paperless -c "python3 manage.py collectstatic --clear --no-input --link" \
  && su paperless -c "python3 manage.py compilemessages"

ENV PAPERLESS_REDIS="redis://localhost:6379"


VOLUME ["/usr/src/paperless/data", \
        "/usr/src/paperless/media", \
        "/usr/src/paperless/consume", \
        "/usr/src/paperless/export"]

ENTRYPOINT ["/sbin/docker-entrypoint.sh"]

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
