FROM fedora:30
MAINTAINER "Peter Schiffer" <peter@rfv.sk>

RUN dnf -y install \
    burp-client \
    gettext \
    hostname \
  && dnf clean all \
  && rm -f /etc/burp/burp.conf

ENV BURP_SERVER=burp \
    BURP_SERVER_PORT=4971 \
    BURP_CLIENT_PASSWORD=BurpClient123

VOLUME [ "/etc/burp" ]

COPY burp.conf.tpl /etc/burp/burp.conf.tpl
COPY docker-cmd.sh /docker-cmd.sh

CMD [ "/docker-cmd.sh" ]
