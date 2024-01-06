FROM rockylinux/rockylinux:9-ubi

RUN echo 'install_weak_deps=False' >> /etc/dnf/dnf.conf \
  && echo 'tsflags=nodocs' >> /etc/dnf/dnf.conf \
  && echo 'assumeyes=True' >> /etc/dnf/dnf.conf \
  && dnf install dnf-plugins-core epel-release \
  && dnf config-manager --set-disabled epel-cisco-openh264 \
  && dnf config-manager --set-enabled crb \
  && dnf --refresh upgrade \
  && dnf install \
    python3-gevent \
    python3-gunicorn \
    python3-pip \
  && dnf clean all

RUN pip3 install --no-cache-dir \
    'burp-ui[ldap_authentication]' \
    'Werkzeug<3' \
    envtpl \
  && mkdir -p /etc/burp /etc/burp.tpl

EXPOSE 5000

VOLUME [ "/etc/burp" ]

COPY burpui.cfg.tpl /etc/burp.tpl/burpui.cfg.tpl
COPY docker-cmd.sh /docker-cmd.sh

ENV LANG="en_US.UTF-8"

CMD [ "/docker-cmd.sh" ]
