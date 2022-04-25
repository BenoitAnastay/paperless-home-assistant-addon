ARG BUILD_FROM
FROM $BUILD_FROM

#Dependencies
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
    build-essential \
    curl \
    file \
    fonts-liberation \
    gettext \
    gosu \
    ghostscript \
    gnupg \
    icc-profiles-free \
    imagemagick \
    jq \
    libatlas-base-dev \
    libffi-dev \
    libssl-dev \
    liblept5 \
    libmagic-dev \
    libpq-dev \
    libqpdf-dev \
    libxml2 \
    libxml2-dev \
    libxslt1-dev \
    optipng \
    p7zip-full \
    pngquant \
    python3-pip \
    python3-dev \
    python3-scipy \
    qpdf \
    sudo \
    tesseract-ocr \
    tesseract-ocr-eng \
    tesseract-ocr-deu \
    tesseract-ocr-fra \
    tesseract-ocr-ita \
    tesseract-ocr-spa \
    tzdata \
    unpaper \
    unzip \
    wget \
    zlib1g \
    && mkdir /var/log/supervisord /var/run/supervisord

RUN wget -O paperless.tar.xz https://github.com/paperless-ngx/paperless-ngx/releases/download/ngx-1.6.0/paperless-ngx-1.6.0.tar.xz \
    && 7z x paperless.tar.xz \
    && 7z x paperless.tar -o/usr/src/ \
    && cd /usr/src 

# Fix aarch64 builds
# see: https://github.com/pikepdf/pikepdf/issues/194#issuecomment-1020419586
RUN wget -O qpdf.tar.gz https://github.com/qpdf/qpdf/releases/download/release-qpdf-10.6.3/qpdf-10.6.3.tar.gz \
    && tar zxf qpdf.tar.gz \
    && mv qpdf-10.6.3 qpdf \
    && ls -lah \
    && cd /qpdf \
    && ./configure \
    && make

WORKDIR /usr/src/paperless-ngx/

# We need to make the directory before coping to it
RUN mkdir -p /usr/src/paperless/src
RUN cp requirements.txt /usr/src/paperless/requirements.txt

# copy app
RUN cp -R ./src /usr/src/paperless/


# Install requirements
RUN python3 -m pip install --upgrade pip supervisor setuptools \
    && env QPDF_SOURCE_TREE=/qpdf python3 -m pip install --no-cache-dir -r requirements.txt

#### Redis Setup
RUN apt-get install redis-server redis-tools -y
RUN sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf

# Clean Up
RUN apt-get -y purge build-essential libqpdf-dev \
    && apt-get -y autoremove --purge \
    && rm -rf /var/lib/apt/lists/* 

# copy scripts
# FROM ORIGINAL DOCKER FILE: this fixes issues with imagemagick and PDF
RUN cp docker/imagemagick-policy.xml /etc/ImageMagick-6/policy.xml
RUN cp gunicorn.conf.py /usr/src/paperless
RUN cp docker/supervisord.conf /etc/supervisord.conf
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
RUN sudo chmod +x scripts/wait-for-redis.sh

RUN sudo -HEu paperless python3 manage.py collectstatic --clear --no-input

RUN sudo -HEu paperless python3 manage.py compilemessages


VOLUME ["/usr/src/paperless/data", "/usr/src/paperless/media", "/usr/src/paperless/consume", "/usr/src/paperless/export"]

COPY scripts/setup_superuser.py scripts/setup_superuser.py
ENTRYPOINT ["/bin/bash", "/sbin/docker-entrypoint.sh"]
EXPOSE 8000


CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]

LABEL maintainer="Moshe <34072688+TheBestMoshe@users.noreply.github.com>"
