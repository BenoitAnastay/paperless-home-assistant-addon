# Paperless-ng Home Assistant Addon
### Paperless Version 1.17.4

## About

_Paperless is an application that manages your personal documents. With the help of a document scanner (see [Scanner recommendations](https://paperless-ngx.readthedocs.io/en/latest/scanners.html)), paperless transforms your wieldy physical document binders into a searchable archive and provides many utilities for finding and managing your documents._

![Dashboard screenshot](https://github.com/paperless-ngx/paperless-ngx/blob/b961df90a72f506f4a58c236fd3712cebb1523ff/docs/assets/screenshots/dashboard.png)

Read more in the project's [Readme](https://github.com/paperless-ngx/paperless-ngx)

## Installation

The installation of this add-on is pretty straightforward and not different in
comparison to installing any other Home Assistant add-on.

1. Add Add this URL to your Home Assistant addons repos (Supervisor -> Add-on store -> three dots upper right): `https://github.com/Rudertier/paperless-home-assistant-addon`
1. Install this add-on.
1. Set the configuration.
1. Click the `Save` button to store your configuration.
1. Start the add-on.
1. Check the logs of the add-on to see if everything went well.

## Documentation

The documentation for this addon can be found [here](DOCS.md)

## Integrate into Home Assistant

In Home Assistant Information from paperless can be accessed trought a REST-Sensor:
```
- platform: rest
  unique_id: 5dade7bc-ddb7-442e-bb17-0d379dbf01fb
  resource: paperless.server:port/api/documents/
  headers:
    Authorization: !secret paperless_auth_header
  params:
    query: "tag:inbox"
  value_template: "{{ value_json.count | int }}"
  name: "Paperless Inbox"
  icon: mdi:inbox
```

In your secrets file you'll have to specify:
```
paperless_auth_header: Token <django-token>
```

You can generate a token by clicking on `Settings -> Django Adminpanel -> Token` in your paperless instance.
