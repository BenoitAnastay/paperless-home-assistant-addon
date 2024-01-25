# Paperless-ngx

_Paperless is an application that manages your personal documents. With the help of a document scanner (see [Scanner recommendations](https://paperless-ngx.readthedocs.io/en/latest/scanners.html#scanners)), paperless transforms your wieldy physical document binders into a searchable archive and provides many utilities for finding and managing your documents._

## Installation

The installation of this add-on is pretty straightforward and not different in
comparison to installing any other Home Assistant add-on.

1. Click the Home Assistant My button below to open the add-on on your Home
   Assistant instance.

   [![Open this add-on in your Home Assistant instance.][addon-badge]][addon]

1. Click the "Install" button to install the add-on.
1. Start the "Paperless-ngx" add-on.
1. Check the logs of the "Paperless-ngx" add-on to see it in action.

## File Storage

Media files are stored in the `share/paperless` directory. This includes the `consume` and `media` directories. Files added into `consume` will be ingested by Paperless.

`paperless.conf` file and `data` directory are located in `/addon_config/paperless_ngx`

## Backing up

The simplest way is to make a backup is to make a Home Assistant snapshot and include `share`.

Another way is to make a copy of the `data` and `media` directories.

**NOTE: Making a snapshot that includes this addon but does not include the `share` directory will not back up your data!!**

## CSRF Validation Failled

There is a validation of domain name used for some requests, those domains are extracted from Internal URL, External URL and Hostname of home assistant.

You can find those settings in the network configuration of Home Assistant

[![Open your Home Assistant instance and manage your systems network configuration.](https://my.home-assistant.io/badges/network.svg)](https://my.home-assistant.io/redirect/network/)

When set to automatic, those settings cannot be resolved by the Add-on therefore you might need to setup your Internal and External URL manually

### Reverse Proxy and dedicated URL

For URL dedicated to paperless you'll have to set `url` in configuration tab of the Add-on (see bellow)

## Ingress and API

For API you'll need to enable _direct access_ to the Add-on by setting up a port under network in configuration tab

## Configuration

**Note**: _Remember to restart the add-on when the configuration is changed._

```yaml
url: http://example.com
filename: "{created_year}/{correspondent}/{title}"
language: eng
language_packages: eng deu fra ita spa
default_superuser:
  username: admin
  email: admin@example.com
  password: changeme
timezone: Europe/Paris
polling_interval: 0
barcodes_enabled: false
barcodes_asn: false
consumer_recursive: false
consumer_subdirs_as_tags: false
ssl: false
certfile: fullchain.pem
keyfile: privkey.pem
```

### Option: `url`

https://paperless-ngx.readthedocs.io/en/latest/configuration.html?highlight=paperless_url#hosting-security

### Option: `csrf_allowed`

Used to add domains to`PAPERLESS_CSRF_TRUSTED_ORIGINS`

https://paperless-ngx.readthedocs.io/en/latest/configuration.html?highlight=paperless_url#hosting-security

### Option: `filename`

https://paperless-ngx.readthedocs.io/en/latest/advanced_usage.html#advanced-file-name-handling

### Option: `language`

Can be `eng`, `deu`, `fra`, `ita`, `spa`.
This can be a combination of multiple languages such as deu+eng, in which case tesseract will use whatever language matches best.
[Docs](https://paperless-ngx.readthedocs.io/en/latest/configuration.html#ocr-settings)

### Option: `language_packages`

This is the list of language packages to install, separated by space

### Option: `default_superuser`

When the addon starts up, if this user is not created, it will create it.

### Option: `timezone`

Set the timezone of Paperless defaults to UTC. (Options are: Europe/Berlin, Asia/Bishkek and [many more](https://docs.djangoproject.com/en/4.1/ref/settings/#std:setting-TIME_ZONE))

### Option: `polling_interval`

If paperless won't find documents added to your consume folder, it might not be able to automatically detect filesystem changes. In that case, specify a polling interval in seconds here, which will then cause paperless to periodically check your consumption directory for changes. This will also disable listening for file system changes with inotify.
[Docs](https://docs.paperless-ngx.com/configuration/#PAPERLESS_CONSUMER_POLLING))

### Option: `barcodes_enabled`

Enables the scanning and page separation based on detected barcodes. This allows for scanning and adding multiple documents per uploaded file, which are separated by one or multiple barcode pages.[Docs](https://docs.paperless-ngx.com/configuration/#PAPERLESS_CONSUMER_ENABLE_BARCODES))

### Option: `barcodes_asn`

Enables the detection of barcodes in the scanned document and setting the ASN (archive serial number) if a properly formatted barcode is detected.
[Docs](https://docs.paperless-ngx.com/configuration/#PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE))

### Option: `consumer_recursive`

Enable recursive watching of the consumption directory. Paperless will then pickup files from files in subdirectories within your consumption directory as well.
[Docs](https://docs.paperless-ngx.com/configuration/#PAPERLESS_CONSUMER_RECURSIVE))

### Option: `consumer_subdirs_as_tags`

Set the names of subdirectories as tags for consumed files. E.g.
`<CONSUMPTION_DIR>/foo/bar/file.pdf` will add the tags "foo" and
"bar" to the consumed file. Paperless will create any tags that
don't exist yet.
[Docs](https://docs.paperless-ngx.com/configuration/#PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS))

### Option: `ssl`

Enables/Disables SSL (HTTPS) on the web interface of Grocy
Panel. Set it `true` to enable it, `false` otherwise.

### Option: `certfile`

The certificate file to use for SSL.

**Note**: _The file MUST be stored in `/ssl/`, which is the default_

### Option: `keyfile`

The private key file to use for SSL.

**Note**: _The file MUST be stored in `/ssl/`, which is the default_

### Option: `max_upload`

Let you set `client_max_body_size` of _nginx_ manually

### More personalisation

You can add more configurations options in `/addon_config/paperless_ngx/paperless.conf`

[addon-badge]: https://my.home-assistant.io/badges/supervisor_addon.svg
[addon]: https://my.home-assistant.io/redirect/supervisor_addon/?addon=ca5234a0_paperless-ngx&repository_url=https%3A%2F%2Fgithub.com%2FBenoitAnastay%2Fhome-assistant-addons-repository
