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
RUN apk add --no-cache \
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
        qpdf

RUN wget -q -O paperless.tar.xz https://github.com/BenoitAnastay/paperless-ngx/releases/download/v1.17.4/paperless-ngx-v1.17.4.tar.xz \
    && tar -xf paperless.tar.xz \
    && mv paperless-ngx /opt/paperless

WORKDIR /opt/paperless

# Install requirements
# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir --upgrade wheel \
    && pip3 install --no-cache-dir --ignore-installed -r requirements.txt


# Download NLTK Stopwords
RUN mkdir -p /usr/src/paperless/nltk
ENV PAPERLESS_NLTK_DIR="/usr/src/paperless/nltk"
# hadolint ignore=SC1072
RUN [ "python3", "-c", "import nltk; nltk.download('all', download_dir='/usr/src/paperless/nltk')" ]

#### Redis Setup
# hadolint ignore=DL3008
RUN sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf \
    && apk del --no-cache --purge .build-dependencies

# copy scripts
# FROM ORIGINAL DOCKER FILE: this fixes issues with imagemagick and PDF
RUN cp docker/imagemagick-policy.xml /etc/ImageMagick-6/policy.xml \
    && cp gunicorn.conf.py /usr/src/paperless \
    && cp docker/supervisord.conf /etc/supervisord.conf

# RUN cp docker/docker-entrypoint.sh /sbin/docker-entrypoint.sh
COPY scripts/docker-entrypoint.sh /sbin/docker-entrypoint.sh
COPY scripts/docker-prepare.sh /sbin/docker-prepare.sh


WORKDIR /usr/src/paperless

# add users, setup scripts
RUN addgroup --gid 1000 paperless \
    && useradd --uid 1000 --gid paperless --home-dir /usr/src/paperless paperless \
    && chown -R paperless:paperless . \
    && chmod 755 /sbin/docker-entrypoint.sh

WORKDIR /usr/src/paperless/src/

ENV PAPERLESS_REDIS="redis://localhost:6379"

COPY scripts/wait-for-redis.sh scripts/wait-for-redis.sh
RUN chmod +x scripts/wait-for-redis.sh

RUN paperless python3 manage.py collectstatic --clear --no-input \
    && paperless python3 manage.py compilemessages


VOLUME ["/usr/src/paperless/data", "/usr/src/paperless/media", "/usr/src/paperless/consume", "/usr/src/paperless/export"]

COPY scripts/setup_superuser.py scripts/setup_superuser.py
ENTRYPOINT ["/bin/bash", "/sbin/docker-entrypoint.sh"]
EXPOSE 8000


CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]

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
