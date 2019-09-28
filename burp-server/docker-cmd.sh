#!/bin/bash

set -euo pipefail

BURP_DATA_DIRECTORY=/var/spool/burp

# Rsync stunnel
if [ "${STUNNEL_RSYNC_HOST:-}" ]; then
  envsubst < /etc/stunnel/rsync.conf.tpl > /etc/stunnel/rsync.conf
  systemctl enable stunnel@rsync
fi

# Rsync script
envsubst '$RSYNC_DEST $RSYNC_PASS' < /rsync.sh.tpl > /rsync.sh
chmod +x /rsync.sh

# Restore from rsync
if [ "${RESTORE_FROM_RSYNC:-}" ] && [ ! "$(ls -A /var/spool/burp)" ]; then
  if [ "${STUNNEL_RSYNC_HOST:-}" ]; then
    /usr/bin/stunnel /etc/stunnel/rsync.conf &
    sleep 3
  fi

  /rsync.sh --restore

  if [ "${STUNNEL_RSYNC_HOST:-}" ]; then
    pkill stunnel
  fi
fi

# Encryption
if [ "${ENCRYPT_PASSWORD:-}" ]; then
  mkdir -p /var/spool/burp-plain
  BURP_DATA_DIRECTORY=/var/spool/burp-plain
  echo "$ENCRYPT_PASSWORD" | encfs -S --standard /var/spool/burp /var/spool/burp-plain
fi

# Configuration
if [ -z "$(ls -A /etc/burp)" ]; then
  cp -a /etc/burp.tpl/* /etc/burp/
  SSL_KEY_PASSWORD=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 32) || true
  CLIENT_PASSWORD=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 32) || true
  export SSL_KEY_PASSWORD CLIENT_PASSWORD BURP_DATA_DIRECTORY
  envsubst < /etc/burp.tpl/burp-server.conf > /etc/burp/burp-server.conf
  envsubst < /etc/burp.tpl/burp.conf > /etc/burp/burp.conf
  envsubst < /etc/burp.tpl/clientconfdir/localclient > /etc/burp/clientconfdir/localclient
  envsubst < /etc/burp.tpl/buiagent.cfg > /etc/burp/buiagent.cfg
fi

# configure burp clients
# $BURP_CLIENTS_CONFIG has to be in the format: 'host1:pass1 host2:pass2 host3:pass3'
if [ -n "$BURP_CLIENTS_CONFIG" ]; then
  for i in $BURP_CLIENTS_CONFIG; do
    CLIENT_PASSWORD="${i#*:}"
    export CLIENT_PASSWORD
    envsubst < /etc/burp.tpl/clientconfdir/localclient > "/etc/burp/clientconfdir/${i%:*}"
  done
fi

exec /usr/sbin/init
