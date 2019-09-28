#!/bin/bash

set -euo pipefail

if [ -z "$(ls -A /etc/burp)" ]; then
  cp -a /etc/burp.tpl/* /etc/burp/
  BURPUI_APP_SECRET=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 32) || true
  sed -i "s/appsecret = random/appsecret = ${BURPUI_APP_SECRET}/g" /etc/burp/burpui.cfg.tpl
fi

envtpl < /etc/burp/burpui.cfg.tpl > /etc/burp/burpui.cfg

export LANG='en_US.UTF-8'
#exec /usr/bin/gunicorn -k gevent -w 4 --access-logfile - -b '0.0.0.0:5000' 'burpui:create_app(conf="/etc/burp/burpui.cfg", verbose=3)'
exec /usr/bin/gunicorn-3 -k gevent -w 4 --access-logfile - -b '0.0.0.0:5000' 'burpui:create_app(conf="/etc/burp/burpui.cfg", verbose=3)'
