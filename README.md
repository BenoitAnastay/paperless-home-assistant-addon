# Home Assistant Addons Repository

## About

Home Assistant allows anyone to create add-on repositories to share their add-ons for Home Assistant easily. This repository is one of those repositories, providing extra Home Assistant add-ons for your installation.

In the Home Assistant add-on store, a possibility to add a repository is provided.

Use the following URL to add this repository:

```
https://github.com/TheBestMoshe/home-assistant-addons
```

## Add-ons provided by this repository

### [Paperless-ngx](paperless-ngx)

[Docs](paperless-ngx/DOCS.md)


## Develop on Gitpod
I use [Gitpod](https://gitpod.io/) to develop my Home Assistant addons. Use the commands listed below to build and run the addons.

### Paperless-ngx

```
docker build --build-arg BUILD_FROM="homeassistant/amd64-base-debian:latest" -t local/paperless-ngx ./paperless-ngx/
docker run -p 8000:8000 -v $PWD/paperless-ngx/data:/data local/paperless-ngx
```
