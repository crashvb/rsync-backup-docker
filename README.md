# rsync-backup-docker

[![version)](https://img.shields.io/docker/v/crashvb/rsync-backup/latest)](https://hub.docker.com/repository/docker/crashvb/rsync-backup)
[![image size](https://img.shields.io/docker/image-size/crashvb/rsync-backup/latest)](https://hub.docker.com/repository/docker/crashvb/rsync-backup)
[![linting](https://img.shields.io/badge/linting-hadolint-yellow)](https://github.com/hadolint/hadolint)
[![license](https://img.shields.io/github/license/crashvb/rsync-backup-docker.svg)](https://github.com/crashvb/rsync-backup-docker/blob/master/LICENSE.md)


## Overview

This docker image contains rsync-backup

## Entrypoint Scripts

### rsync-backup

The embedded entrypoint script is located at `/etc/entrypoint.d/rsync-backup` and performs the following actions:

1. A new rsync-backup configuration is generated using the following environment variables:

 | Variable | Default Value | Description |
 | -------- | ------------- | ----------- |
 | RSYNC\_BACKUP\_CONF | | If defined, this value will be written to `<rsync-backup_conf>/rsync-backup.conf`. |

2. Volume permissions are normalized.

## Standard Configuration

### Container Layout

```
/
├─ etc/
│  ├─ cron.daily/
│  │  └─ rsync-backup
│  ├─ rsync-backup/
│  └─ entrypoint.d/
│     └─ rsync-backup
├─ run/
│  └─ secrets/
│     ├─ id_rsa.rsync-backup
│     └─ id_rsa.rsync-backup.pub
└─ var/
   ├─ lib/
   │  └─ rsync-backup/
   └─ log/
      └─ rsync-backup*
```

### Exposed Ports

None.

### Volumes

* `/etc/rsync-backup` - rsync-backup configuration directory.
* `/var/lib/rsync-backup` - rsync-backup data directory.

## Development

[Source Control](https://github.com/crashvb/rsync-backup-docker)

