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

All the files are stored in the `share/paperless` directory. This includes the `consume` directory as well as the `data` and `media` directories. Files added into `consume` will be ingested by Paperless.

## Backing up

The simplest way is to make a backup is to make a Home Assistant snapshot and include `share`.

Another way is to make a copy of the `data` and `media` directories.

**NOTE: Making a snapshot that includes this addon but does not include the `share` directory will not back up your data!!**

## Configuration

**Note**: _Remember to restart the add-on when the configuration is changed._

```yaml
url: http://example.com
filename:
  format: "{created_year}/{correspondent}/{title}"
ocr:
  language: eng
default_superuser:
  username: admin
  email: admin@example.com
  password: changeme
```

### Option: `url`

https://paperless-ngx.readthedocs.io/en/latest/configuration.html?highlight=paperless_url#hosting-security

### Option: `filename.format`

https://paperless-ngx.readthedocs.io/en/latest/advanced_usage.html#advanced-file-name-handling

### Option: `ocr.language`

Can be `eng`, `deu`, `fra`, `ita`, `spa`.
This can be a combination of multiple languages such as deu+eng, in which case tesseract will use whatever language matches best.
[Docs](https://paperless-ngx.readthedocs.io/en/latest/configuration.html#ocr-settings)

### Option: `default_superuser`

When the addon starts up, if this user is not created, it will create it.

### Option: `timezone`

Set the timezone of Paperless defaults to UTC. (Options are: Europe/Berlin, Asia/Bishkek and [many more](https://docs.djangoproject.com/en/4.1/ref/settings/#std:setting-TIME_ZONE))
