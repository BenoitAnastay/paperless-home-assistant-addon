# Home Assistant Addons Repository

## About

Home Assistant allows anyone to create add-on repositories to share their add-ons for Home Assistant easily. This repository is one of those repositories, providing extra Home Assistant add-ons for your installation.

In the Home Assistant add-on store, a possibility to add a repository is provided.

Use the following URL to add this repository:

```
https://github.com/TheBestMoshe/home-assistant-addons
```

## Add-ons provided by this repository

### [Paperless-ng](paperless-ng)

[Docs](paperless-ng/DOCS.md)


## Develop on Gitpod
I use [Gitpod](https://gitpod.io/) to develop my Home Assistant addons. Use the commands listed below to build and run the addons.

### Paperless-ng

```
docker build --build-arg BUILD_FROM="homeassistant/amd64-base-debian:latest" -t local/paperless-ng ./paperless-ng/
docker run -p 8000:8000 -v $PWD/paperless-ng/data:/data local/paperless-ng
```
