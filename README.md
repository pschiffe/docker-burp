# Burp Backup in Docker

This repository contains Docker images for the [Burp](http://burp.grke.org/) server, client, and [web UI](https://git.ziirish.me/ziirish/burp-ui). All images are available at Docker Hub:

https://hub.docker.com/r/pschiffe/burp-server/

https://hub.docker.com/r/pschiffe/burp-client/

https://hub.docker.com/r/pschiffe/burp-ui/

Source GitHub repository: https://github.com/pschiffe/docker-burp

---
[![Static Badge](https://img.shields.io/badge/GitHub_Sponsors-grey?logo=github)](https://github.com/sponsors/pschiffe) [![Static Badge](https://img.shields.io/badge/paypal.me-grey?logo=paypal)](https://www.paypal.com/paypalme/pschiffe)

If this project is useful to you, please consider sponsoring me to support maintenance and further development. Thank you!

## Burp Server

![Docker Image Size (tag)](https://img.shields.io/docker/image-size/pschiffe/burp-server/latest) ![Docker Pulls](https://img.shields.io/docker/pulls/pschiffe/burp-server)

https://hub.docker.com/r/pschiffe/burp-server/

The Burp server image includes optional encryption, secure rsync to a remote location, and a [bui-agent](https://burp-ui.readthedocs.io/en/latest/buiagent.html) for the web UI.

### Persistent data

The container utilizes two persistent volumes: `/etc/burp` for configuration files and `/var/spool/burp` for storing backups.

### Systemd

Systemd is used to manage multiple processes within the container. This requires `/run` and `/tmp` to be mounted on `tmpfs`, and currently, the container must run with privileged access. Example Docker run bit when running on Red Hat based distro: `--tmpfs /run --tmpfs /tmp --privileged`

If you are using SELinux on the host, you need to enable the `container_manage_cgroup` variable with `setsebool -P container_manage_cgroup 1`.

Additionally, if you want to see the logs with the `docker logs` command, allocate a tty for the container with the `-t, --tty` option.

### Adding clients

The client configuration can be automatically generated on the server using the `BURP_CLIENTS_CONFIG` environment variable. The format of this variable is: `'client1-hostname:client1-password client2-hostname:client2-password ...'`

### Example

```
docker run -dt -p 4971:4971 --name burp-server \
  -v burp-server-conf:/etc/burp \
  -v burp-server-data:/var/spool/burp \
  -e 'BURP_CLIENTS_CONFIG=host1:pass1 host2:pass2 host3:pass3'
  --tmpfs /run --tmpfs /tmp --privileged \
  pschiffe/burp-server
```

### Encryption

You can encrypt backup data using `EncFS`. To use it, simply provide encryption password in `ENCRYPT_PASSWORD` env var. Because the EncFS is fuse fs, you need to expose the `/dev/fuse` to the container with `--device /dev/fuse`, provide additional capability and possibly disable selinux (or apparmor) confinement with `--cap-add SYS_ADMIN --security-opt label:disable`.

### Rsync to remote location

To regularly synchronize your backup data with a remote location, you can utilize the built-in Rsync support. With `RSYNC_DEST` env var specify remote location in format `rsync://user@server/path`. Password for rsync user can be provided in `RSYNC_PASS` env var. If the remote location provides rsync secured with stunnel, you can use that as well. Specify remote server and port in `STUNNEL_RSYNC_HOST` env var in format `server:port` and then, change the server part of the `RSYNC_DEST` to `localhost`, as in `rsync://user@localhost/path`.

If at least `RSYNC_DEST` env var is set, timer script in the container will try to rsync the local data to the remote location at around 6 AM every morning (this can be modified in `/etc/systemd/system/rsync-sync.timer` file).

And that's not all, there is one more feature - if you set `RESTORE_FROM_RSYNC` env var to `1` and `/var/spool/burp` directory is empty, the container will try to download all the data from remote location with rsync (required rsync connection env vars must be set).

## Burp Web UI

![Docker Image Size (tag)](https://img.shields.io/docker/image-size/pschiffe/burp-ui/latest) ![Docker Pulls](https://img.shields.io/docker/pulls/pschiffe/burp-ui)

https://hub.docker.com/r/pschiffe/burp-ui/

The Burp UI image contains an awesome [web UI for Burp created by Ziirish](https://git.ziirish.me/ziirish/burp-ui). If you're running this container on the same host as the Burp server, you can link this container to the Burp server using the alias `burp`. This is essentially all you need to do. The web service is listening on port `5000`. If you want to manage the Burp server on a different host, you first need to specify the `BUI_AGENT_PASSWORD` environment variable and expose port `10000` of the **burp-server** container. Then, you need to manually edit the `/etc/burp/burpui.cfg.tpl` file in the burp-ui container and add a new `[Agent:name]` section to it. Be sure to update the template file `burpui.cfg.tpl` as the `burpui.cfg` file is overwritten every time the container starts.

### Persistent data

`/etc/burp` directory contains configuration for this container.

### Example

```
docker run -d -p 5000:5000 --name burp-ui \
  -v burp-ui-conf:/etc/burp \
  --link burp-server:burp \
  pschiffe/burp-ui
```

## Burp Client

![Docker Image Size (tag)](https://img.shields.io/docker/image-size/pschiffe/burp-client/latest) ![Docker Pulls](https://img.shields.io/docker/pulls/pschiffe/burp-client)

https://hub.docker.com/r/pschiffe/burp-client/

To back up data and send it to the Burp server, you need the Burp client. Usage of this image is pretty simple. With the `BURP_SERVER` and `BURP_SERVER_PORT` environment variables, you can specify the address and port of the Burp server. The client password goes in the `BURP_CLIENT_PASSWORD` environment variable, and everything you need to back up should be mounted to the `/tobackup` directory in the container. Be aware, however, that you might need to use the `--security-opt label:disable` option when accessing various system directories on the host. It's also possible to link the client to the Burp server container with the alias `burp`. I recommend setting the container hostname to something meaningful, as the client will be identified by its hostname in the Burp server configuration.

### Persistent data

`/etc/burp` persistent directory in the container stores Burp client configuration.

### Example

```
docker run -d --name burp-client \
  -e BURP_SERVER=some-server.host \
  -e BURP_CLIENT_PASSWORD=super-secret \
  -v burp-client-conf:/etc/burp \
  -v /etc:/tobackup/somehost-etc:ro \
  -v /home:/tobackup/somehost-home:ro \
  -v some-docker-vol:/tobackup/some-docker-vol:ro \
  --hostname $HOSTNAME \
  --security-opt label:disable \
  pschiffe/burp-client
```

Once this container is started, it backs up the specified data and exits. After that, I recommend starting the container approximately every 20 minutes using `docker start burp-client`. This allows the container to check with the server and back up new files if scheduled. Please note that the backup schedule is determined by the server, not the client.

### Data recovery

You can also use this container to recover data from a remote server. You simply need to provide arguments in the same way you would for a regular Burp client CLI, for example:
```
docker run -d --name burp-client \
  -e BURP_SERVER=some-server.host \
  -e BURP_CLIENT_PASSWORD=super-secret \
  -v burp-client-conf:/etc/burp \
  -v /etc:/tobackup/somehost-etc \
  --hostname $HOSTNAME \
  --security-opt label:disable \
  pschiffe/burp-client \
  -al /tobackup/somehost-etc
```
