#!/bin/bash

set -euo pipefail

if [ ! -f /etc/burp/burp.conf ]; then
    SSL_KEY_PASSWORD=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 32) || true
    sed -i "s/ssl_key_password = password/ssl_key_password = ${SSL_KEY_PASSWORD}/g" /etc/burp/burp.conf.tpl
fi

envsubst < /etc/burp/burp.conf.tpl > /etc/burp/burp.conf

wait-for-it.sh "${BURP_SERVER}:${BURP_SERVER_PORT}"

exec /usr/sbin/burp $*
