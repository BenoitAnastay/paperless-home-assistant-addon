# Paperless-ng

Paperless is an application that manages your personal documents. With the help of a document scanner (see [Scanner recommendations](https://paperless-ng.readthedocs.io/en/latest/scanners.html#scanners)), paperless transforms your wieldy physical document binders into a searchable archive and provides many utilities for finding and managing your documents.

## Installation

The installation of this add-on is pretty straightforward and not different in
comparison to installing any other Home Assistant add-on.

1. Add Add this url to your hass.io addons repos (Supervisor -> Add-on store -> three dots upper right): `https://github.com/TheBestMoshe/home-assistant-addons`
1. Update the addons list
1. Install

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

https://paperless-ng.readthedocs.io/en/latest/advanced_usage.html#advanced-file-name-handling

### Option: `ocr.language`

Can be `eng`, `deu`, `fra`, `ita`, `spa`.
This can be a combination of multiple languages such as deu+eng, in which case tesseract will use whatever language matches best.
[Docs](https://paperless-ng.readthedocs.io/en/latest/configuration.html#:~:text=PAPERLESS_OCR_LANGUAGE)

### Option: `default_superuser`

When the addon starts up, if this user is not created, it will create it.
