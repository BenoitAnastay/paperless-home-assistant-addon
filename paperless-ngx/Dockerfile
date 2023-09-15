ARG BUILD_FROM=ghcr.io/hassio-addons/base:14.1.0
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Add env
ENV TERM="xterm-256color"

# Setup base
ARG version=v1.17.4

## WIP : Need to change repository to 3.15 and downgrade packages
RUN \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.15/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.15/community" >> /etc/apk/repositories

# hadolint ignore=DL3003,DL3042
RUN \
    apk update \
    && apk add --no-cache musl=1.2.2-r9 \
    && apk add --no-cache --virtual .build-dependencies \
        freetype-dev=2.11.1-r2 \
        gcc=10.3.1_git20211027-r0 \
        g++=10.3.1_git20211027-r0 \
        gfortran=10.3.1_git20211027-r0 \
        musl-dev=1.2.2-r9 \
        libpq-dev=14.9-r0 \
        mariadb-dev=10.6.14-r0 \
        mariadb-connector-c-dev=3.1.13-r2 \
        openblas-dev=0.3.18-r1 \
        qpdf-dev=10.4.0-r0 \
        make=4.3-r0	\
    && apk add --no-cache \
        python3=3.9.18-r0 \
        py3-pip=20.3.4-r1 \
        python3-dev=3.9.18-r0 \
        openblas=0.3.18-r1 \
        qpdf=10.4.0-r0 \
        ttf-liberation=2.00.5-r0 \
        imagemagick=7.1.0.16-r0	\
        gnupg=2.2.31-r2 \
        file=5.41-r0 \
        mailcap=2.1.54-r0 \
        libmagic=5.41-r0 \
        libzbar=0.23.90-r1 \
        poppler-utils=21.11.0-r0 \
        shared-mime-info=2.1-r2	\
        unpaper=6.1-r2 \
        ghostscript=9.55.0-r2 \
        libxml2=2.9.14-r2 \
        libxslt=1.1.35-r0 \
        pngquant=2.16.0-r0 \
        zlib=1.2.12-r3 \
        tesseract-ocr=4.1.3-r0 \
        tesseract-ocr-data-fra=4.1.3-r0	\
        tesseract-ocr-data-deu=4.1.3-r0	\
        tesseract-ocr-data-ita=4.1.3-r0	\
        tesseract-ocr-data-spa=4.1.3-r0	\
        ocrmypdf=12.7.1-r0 \
        redis=6.2.13-r0 \
        supervisor=4.2.2-r2

## WIP : Need to change repository to 3.16 for qpdf
RUN \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.16/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.16/community" >> /etc/apk/repositories

RUN \
    apk update \
    && apk add --no-cache musl=1.2.2-r9 \
    && apk add --no-cache --virtual .build-dependencies \
        qpdf-dev=10.6.3-r0 \
    && apk add --no-cache \
        qpdf=10.6.3-r0

## WIP : revert to 3.15 to avoid later issues 
RUN \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.15/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.15/community" >> /etc/apk/repositories

RUN wget -q -O paperless.tar.xz https://github.com/paperless-ngx/paperless-ngx/releases/download/$version/paperless-ngx-$version.tar.xz \
    && tar -xf paperless.tar.xz \
    && mv paperless-ngx /opt/paperless

WORKDIR /opt/paperless

# Install requirements
# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir -r requirements.txt


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
