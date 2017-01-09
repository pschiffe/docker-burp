FROM fedora:25
MAINTAINER "Peter Schiffer" <pschiffe@redhat.com>

RUN dnf -y --setopt=tsflags=nodocs install \
        python-pip \
        pyOpenSSL \
        python-gevent \
        python-gunicorn \
    && dnf clean all

RUN pip3 install envtpl \
    && rm -rf ~/.cache/*

RUN pip install "burp-ui[ldap_authentication]" \
    && rm -rf ~/.cache/* \
    && mkdir -p /etc/burp /etc/burp.tpl

EXPOSE 5000

VOLUME [ "/etc/burp" ]

COPY burpui.cfg.tpl /etc/burp.tpl/burpui.cfg.tpl
COPY docker-cmd.sh /docker-cmd.sh

CMD [ "/docker-cmd.sh" ]
