ARG BUILD_FROM=ghcr.io/hassio-addons/base:14.1.0
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Add env
ENV TERM="xterm-256color"

# Copy Python requirements file
COPY requirements.txt /tmp/

# Setup base
ARG version=v1.17.4

## WIP : Need to change repository to 3.15 and downgrade packages
RUN \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.15/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.15/community" >> /etc/apk/repositories

# hadolint ignore=DL3003,DL3042
RUN \
    apk update \
    && apk add --no-cache --virtual .build-dependencies \
        freetype-dev=2.13.0-r5 \
        gcc=12.2.1_git20220924-r10 \
        musl-dev=1.2.4-r1 \
    && apk add --no-cache \
        python3=3.9.18-r0 \
        py3-pip=20.3.4-r1 \
        python3-dev=3.9.18-r0 \
        qpdf=11.3.0-r0 \
        font-liberation=2.1.5-r2 \
        imagemagick=7.1.1.13-r0	\
        gnupg=2.4.3-r0 \
        libmagic=5.45-r0 \
        libzbar=0.23.92-r2	\
        poppler-utils=23.05.0-r0 \
        shared-mime-info=2.2-r5	\
        unpaper=7.0.0-r1 \
        ghostscript=10.01.2-r0 \
        libxml2=2.11.4-r0 \
        pngquant=3.0.1-r1 \
        zlib=1.2.13-r1 \
        tesseract-ocr=5.3.2-r0 \
        tesseract-ocr-data-eng=5.3.2-r0	\
        tesseract-ocr-data-fra=5.3.2-r0	\
        ocrmypdf=14.1.0-r1 \
        redis=7.0.13-r0	


RUN wget --progress=dot:giga -O paperless.tar.xz https://github.com/paperless-ngx/paperless-ngx/releases/download/$version/paperless-ngx-$version.tar.xz \
    && tar -xf paperless-ngx-$version.tar.xz \
    && mv paperless-ngx /opt/paperless

WORKDIR /opt/paperless

# Install requirements
# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir -r requirements.txt


# Download NLTK Stopwords
RUN mkdir -p /usr/src/paperless/nltk
ENV PAPERLESS_NLTK_DIR="/usr/src/paperless/nltk"
# hadolint ignore=SC1072
RUN [ "python3", "-c", "import nltk; nltk.download('all', download_dir='/usr/src/paperless/nltk')" ]

#### Redis Setup
# hadolint ignore=DL3008
RUN apt-get install --no-install-recommends redis-server redis-tools -y && sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf

# Clean Up
RUN apt-get -y purge build-essential libqpdf-dev \
    && apt-get -y autoremove --purge \
    && rm -rf /var/lib/apt/lists/* 

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

LABEL maintainer="Rudertier <Rudertiers@users.noreply.github.com>"
