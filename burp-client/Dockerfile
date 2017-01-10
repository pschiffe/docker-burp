FROM fedora:25
MAINTAINER "Peter Schiffer" <pschiffe@redhat.com>

RUN dnf -y --setopt=tsflags=nodocs install 'dnf-command(copr)' \
    && dnf -y copr enable yopito/burp2 \
    && dnf -y --setopt=tsflags=nodocs install \
        hostname \
        openssl \
        burp2-client \
        gettext \
    && dnf clean all \
    && rm -f /etc/burp/burp.conf

ENV BURP_SERVER=burp \
    BURP_SERVER_PORT=4971 \
    BURP_CLIENT_PASSWORD=BurpClient123

VOLUME [ "/etc/burp" ]

COPY burp.conf.tpl /etc/burp/burp.conf.tpl
COPY docker-cmd.sh /docker-cmd.sh

CMD [ "/docker-cmd.sh" ]
