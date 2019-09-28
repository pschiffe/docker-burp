FROM fedora:30
MAINTAINER "Peter Schiffer" <peter@rfv.sk>

RUN dnf -y install \
    burp-server \
    fuse-encfs \
    gettext \
    hostname \
    nmap-ncat \
    procps-ng \
    python3-cffi \
    python3-gevent \
    python3-pyOpenSSL \
    rsync \
    stunnel \
  && dnf clean all \
  && cp -a /etc/burp /etc/burp.tpl \
  && rm -rf /etc/burp/*

RUN pip3 install --no-cache-dir burp-ui-agent

STOPSIGNAL RTMIN+3
RUN echo 'ForwardToConsole=yes' >> /etc/systemd/journald.conf

ENV container=docker \
    BUI_AGENT_PASSWORD=BurpAgent123

EXPOSE 4971 10000

HEALTHCHECK --interval=10s CMD nc -z 127.0.0.1 4971

VOLUME [ "/etc/burp", "/var/spool/burp" ]

COPY burp-server.conf burp.conf buiagent.cfg /etc/burp.tpl/
COPY localclient /etc/burp.tpl/clientconfdir/localclient
COPY buiagent.service umount-encfs.service rsync-sync.service \
     rsync-sync.timer /etc/systemd/system/
COPY rsync-stunnel.conf.tpl /etc/stunnel/rsync.conf.tpl
COPY rsync.sh.tpl /rsync.sh.tpl
COPY docker-cmd.sh /init

RUN systemctl enable burp \
  && systemctl enable buiagent \
  && systemctl enable umount-encfs \
  && systemctl enable rsync-sync.timer

CMD [ "/init" ]
