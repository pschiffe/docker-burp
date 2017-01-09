# Journald is broken in 25 and later for now https://github.com/docker/docker/issues/27202
FROM fedora:24
MAINTAINER "Peter Schiffer" <pschiffe@redhat.com>

RUN dnf -y --setopt=tsflags=nodocs install 'dnf-command(copr)' \
    && dnf -y copr enable yopito/burp2 \
    && dnf -y --setopt=tsflags=nodocs install \
        hostname \
        burp2-server \
        gettext \
        python3-pyOpenSSL \
        python3-gevent \
        fuse-encfs \
        rsync \
        stunnel \
        procps-ng \
        https://kojipkgs.fedoraproject.org/packages/python-cffi/1.7.0/3.fc25/x86_64/python3-cffi-1.7.0-3.fc25.x86_64.rpm \
    && dnf clean all \
    && cp -a /etc/burp /etc/burp.tpl \
    && rm -rf /etc/burp/*

RUN pip3 install "burp-ui[agent]" \
    && rm -rf ~/.cache/*

STOPSIGNAL SIGRTMIN+3
RUN echo 'ForwardToConsole=yes' >> /etc/systemd/journald.conf

ENV container=docker \
    BUI_AGENT_PASSWORD=BurpAgent123

EXPOSE 4971 10000

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
