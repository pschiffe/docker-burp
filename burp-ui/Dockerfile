FROM fedora:30
MAINTAINER "Peter Schiffer" <peter@rfv.sk>

RUN dnf -y install \
    python3-gevent \
    python3-gunicorn \
  && dnf clean all

RUN pip3 install --no-cache-dir \
    burp-ui[ldap_authentication] \
    envtpl \
  && mkdir -p /etc/burp /etc/burp.tpl

EXPOSE 5000

VOLUME [ "/etc/burp" ]

COPY burpui.cfg.tpl /etc/burp.tpl/burpui.cfg.tpl
COPY docker-cmd.sh /docker-cmd.sh

CMD [ "/docker-cmd.sh" ]
