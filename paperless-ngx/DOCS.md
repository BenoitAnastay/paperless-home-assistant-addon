# Paperless-ng

_Paperless is an application that manages your personal documents. With the help of a document scanner (see [Scanner recommendations](https://paperless-ngx.readthedocs.io/en/latest/scanners.html#scanners)), paperless transforms your wieldy physical document binders into a searchable archive and provides many utilities for finding and managing your documents._

## Installation

The installation of this add-on is pretty straightforward and not different in
comparison to installing any other Home Assistant add-on.

1. Add Add this URL to your Home Assistant addons repos (Supervisor -> Add-on store -> three dots upper right): `https://github.com/TheBestMoshe/home-assistant-addons`
1. Install this add-on.
1. Set the configuration.
1. Click the `Save` button to store your configuration.
1. Start the add-on.
1. Check the logs of the add-on to see if everything went well.

## File Storage

All the files are stored in the `share/paperless` directory. This includes the `consume` directory as well as the `data` and `media` directories. Files added into `consume` will be ingested by Paperless.

## Backing up

The simplest way is to make a backup is to make a Home Assistant snapshot and include `share`.

Another way is to make a copy of the `data` and `media` directories.

**NOTE: Making a snapshot that includes this addon but does not include the `share` directory will not back up your data!!**

## Configuration

**Note**: _Remember to restart the add-on when the configuration is changed._

```yaml
filename:
  format: "{created_year}/{correspondent}/{title}"
ocr:
  language: eng
default_superuser:
  username: admin
  email: admin@example.com
  password: changeme
```

### Option: `filename.format`

https://paperless-ngx.readthedocs.io/en/latest/advanced_usage.html#advanced-file-name-handling

### Option: `ocr.language`

Can be `eng`, `deu`, `fra`, `ita`, `spa`.
This can be a combination of multiple languages such as deu+eng, in which case tesseract will use whatever language matches best.
[Docs](https://paperless-ngx.readthedocs.io/en/latest/configuration.html#ocr-settings)

### Option: `default_superuser`

When the addon starts up, if this user is not created, it will create it.
