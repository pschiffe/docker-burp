# Burp in Docker

This repo contains Docker images with [burp 2.x](http://burp.grke.org/) server, client and a [web ui](https://git.ziirish.me/ziirish/burp-ui). All images are available at Docker Hub:

https://hub.docker.com/r/pschiffe/burp-server/  
https://hub.docker.com/r/pschiffe/burp-client/  
https://hub.docker.com/r/pschiffe/burp-ui/  

## Burp Server

[![](https://images.microbadger.com/badges/image/pschiffe/burp-server.svg)](https://microbadger.com/images/pschiffe/burp-server "Get your own image badge on microbadger.com")

https://hub.docker.com/r/pschiffe/burp-server/

Burp server image with optional encryption, secure rsync to remote location and a [bui-agent](https://burp-ui.readthedocs.io/en/latest/buiagent.html) (for web ui).

### Persistent data

The container uses two persistent volumes - `/etc/burp` for configuration and `/var/spool/burp` for storing backups.

### Sytemd

Systemd is used to manage multiple processes inside of the container, so a couple of special requirements are needed when running it: `/run` and `/tmp` must be mounted on tmpfs, and cgroup filesystem must be bind-mounted from the host. Example Docker run bit when running on Red Hat based distro: `--tmpfs /run --tmpfs /tmp -v /sys/fs/cgroup:/sys/fs/cgroup:ro`

If you are using SELinux on the host, you need to enable the `container_manage_cgroup` variable with `setsebool -P container_manage_cgroup 1`.

Besides that, if you want to see the logs with `docker logs` command, allocate tty for the container with `-t, --tty` option.

### Adding clients

The client configuration can be automatically pre-created on server with `BURP_CLIENTS_CONFIG` env var. The format of this variable is: `'client1-hostname:client1-password client2-hostname:client2-password ...'`

### Example

```
docker run -dt -p 4971:4971 --name burp-server \
  -v burp-server-conf:/etc/burp \
  -v burp-server-data:/var/spool/burp \
  -e 'BURP_CLIENTS_CONFIG=host1:pass1 host2:pass2 host3:pass3'
  --tmpfs /run --tmpfs /tmp -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  pschiffe/burp-server
```

### Encryption

It's possible to encrypt backed up data with `encfs`. To use it, simply provide encryption password in `ENCRYPT_PASSWORD` env var. Because of the encfs fuse fs, you need to expose the `/dev/fuse` to the container with `--device /dev/fuse`, provide additional capability and possibly disable selinux (or apparmor) confinement with `--cap-add SYS_ADMIN --security-opt label:disable`.

### Rsync to remote location

If you want to regularly sync your backed up data to a remote location, you can use the built-in support for rsync. With `RSYNC_DEST` env var specify remote location in format `rsync://user@server/path`. Password for rsync user can be provided in `RSYNC_PASS` env var. If the remote location provides rsync secured with stunnel, you can use that as well. Specify remote server and port in `STUNNEL_RSYNC_HOST` env var in format `server:port` and then, change the server part of the `RSYNC_DEST` to `localhost`, as in `rsync://user@localhost/path`.

If at least `RSYNC_DEST` env var is set, timer script in the container will try to rsync the local data to the remote location at around 6 AM every morning (this can be modified in `/etc/systemd/system/rsync-sync.timer` file).

And that's not all, there is one more feature - if you set `RESTORE_FROM_RSYNC` env var to `1` and `/var/spool/burp` directory is empty, the container will try to download all the data from remote location with rsync (required rsync connection env vars must be set).

## Burp Web UI

[![](https://images.microbadger.com/badges/image/pschiffe/burp-ui.svg)](https://microbadger.com/images/pschiffe/burp-ui "Get your own image badge on microbadger.com")

https://hub.docker.com/r/pschiffe/burp-ui/

Burp UI image contains awesome [web ui for Burp created by Ziirish](https://git.ziirish.me/ziirish/burp-ui). If running this container on the same host as the Burp server, you can just link this container to the Burp server with alias `burp` and more or less that's it. The web service is listening on port `5000`. If you want to manage Burp server on a different host, at first you need to specify `BUI_AGENT_PASSWORD` env var and expose port `10000` of **burp-server** container, then you need to manually edit the `/etc/burp/burpui.cfg.tpl` file in the burp-ui container and add the new `[Agent:name]` section to it. Be sure to update the template file `burpui.cfg.tpl` as the `burpui.cfg` file is overwritten every time the container starts.

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

[![](https://images.microbadger.com/badges/image/pschiffe/burp-client.svg)](https://microbadger.com/images/pschiffe/burp-client "Get your own image badge on microbadger.com")

https://hub.docker.com/r/pschiffe/burp-client/

To backup data and send them to the Burp server, you need Burp client. Usage of this image is pretty simple. With `BURP_SERVER` and `BURP_SERVER_PORT` env vars you can specify an address and port of the Burp server, client password goes in `BURP_CLIENT_PASSWORD` env var and everything you need to backup just mount to `/tobackup` directory in the container. Be aware, however, that you might need to use the `--security-opt label:disable` option when accessing various system directories on the host. It's also possible to link to Burp server container with alias `burp` and I would recommend setting the container hostname to something meaningful, as the client will be identified with its hostname in the Burp server configuration.

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

Once this container is created, it will backup the specified data and exit. After that, it's recommended to start the container ~ every 20 minutes with `docker start burp-client`, so it can check with the server and backup new files if scheduled. The schedule is determined by the server, not the client.
