#!/bin/bash

set -euo pipefail

if [ -z "$(ls -A /etc/burp)" ]; then
  cp -a /etc/burp.tpl/* /etc/burp/
  BURPUI_APP_SECRET=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 32) || true
  sed -i "s/appsecret = random/appsecret = ${BURPUI_APP_SECRET}/g" /etc/burp/burpui.cfg.tpl
fi

envtpl < /etc/burp/burpui.cfg.tpl > /etc/burp/burpui.cfg

exec /usr/bin/gunicorn-3 \
  --worker-class gevent \
  --workers 4 \
  --bind '0.0.0.0:5000' \
  --access-logfile - \
  --pythonpath "$(python3 -c 'import sys; print(",".join(x for x in sys.path if x))')" \
  'burpui:create_app(conf="/etc/burp/burpui.cfg", verbose=3)'
