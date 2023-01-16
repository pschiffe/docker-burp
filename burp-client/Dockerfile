FROM fedora:37

RUN dnf -y install dnf-plugins-core \
  && dnf -y copr enable yopito/burp2 \
  && dnf -y install \
    burp2-client \
    gettext \
    hostname \
    openssl \
  && dnf clean all \
  && rm -f /etc/burp/burp.conf \
  && curl -fsSL https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh > /usr/local/bin/wait-for-it.sh \
  && chmod +x /usr/local/bin/wait-for-it.sh

ENV BURP_SERVER=burp \
    BURP_SERVER_PORT=4971 \
    BURP_CLIENT_PASSWORD=BurpClient123

VOLUME [ "/etc/burp" ]

COPY burp.conf.tpl /etc/burp/burp.conf.tpl
COPY docker-cmd.sh /docker-cmd.sh

ENTRYPOINT [ "/docker-cmd.sh" ]
CMD [ "-a", "t" ]
