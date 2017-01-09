#!/bin/bash

set -euo pipefail

RSYNC_LOCAL_DEST="$RSYNC_DEST"
[ ! "$RSYNC_LOCAL_DEST" ] && exit 0
RSYNC_PASSWORD="$RSYNC_PASS"
[ "$RSYNC_PASSWORD" ] && export RSYNC_PASSWORD

if [ "${1:-}" == '--restore' ]; then
    /usr/bin/rsync -ahvHX "${RSYNC_LOCAL_DEST}/burp/" /var/spool/burp
else
    /usr/bin/rsync -ahvHX --delete /var/spool/burp "$RSYNC_LOCAL_DEST"
fi
