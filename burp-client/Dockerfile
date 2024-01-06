FROM rockylinux/rockylinux:9-ubi

RUN echo 'install_weak_deps=False' >> /etc/dnf/dnf.conf \
  && echo 'tsflags=nodocs' >> /etc/dnf/dnf.conf \
  && echo 'assumeyes=True' >> /etc/dnf/dnf.conf \
  && dnf install dnf-plugins-core epel-release \
  && dnf config-manager --set-disabled epel-cisco-openh264 \
  && dnf config-manager --set-enabled crb \
  && dnf copr enable yopito/burp2 \
  && dnf --refresh upgrade \
  && dnf install \
    burp2-client \
    gettext \
    hostname \
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
