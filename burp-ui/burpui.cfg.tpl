[Global]
# On which port is the application listening
port = 5000
# On which address is the application listening
# '::' is the default for all IPv6
# set it to '0.0.0.0' if you want to listen on all IPv4 addresses
bind = 0.0.0.0
# enable SSL
ssl = false
# ssl cert
sslcert = /etc/burp/ssl_cert-server.pem
# ssl key
sslkey = /etc/burp/ssl_cert-server.key
# burp server version 1 or 2
version = 2
# Handle multiple bui-servers or not
# If set to 'false', you will need to declare at least one 'Agent' section (see
# bellow)
standalone = false
# authentication plugin (mandatory)
# list the misc/auth directory to see the available backends
# to disable authentication you can set "auth = none"
# you can also chain multiple backends. Example: "auth = ldap,basic"
# the order will be respected unless you manually set a higher backend priority
auth = basic
# acl plugin
# list misc/acl directory to see the available backends
# default is no ACL
acl = basic
# You can change the prefix if you are behind a reverse-proxy under a custom
# root path. For example: /burpui
# You can also configure your reverse-proxy to announce the prefix through the
# 'X-Script-Name' header. In this case, the bellow prefix will be ignored in
# favour of the one announced by your reverse-proxy
prefix = none
demo = false

[UI]
# refresh interval of the pages in seconds
refresh = 180
# refresh interval of the live-monitoring page in seconds
liverefresh = 5

[Production]
# storage backend for session and cache
# may be either 'default' or 'redis'
storage = default
# session database to use
# may also be a backend url like: redis://localhost:6379/0
# if set to 'redis', the backend url defaults to:
# redis://<redis_host>:<redis_port>/0
# where <redis_host> is the host part, and <redis_port> is the port part of
# the below "redis" setting
session = default
# cache database to use
# may also be a backend url like: redis://localhost:6379/0
# if set to 'redis', the backend url defaults to:
# redis://<redis_host>:<redis_port>/1
# where <redis_host> is the host part, and <redis_port> is the port part of
# the below "redis" setting
cache = default
# redis server to connect to
redis = localhost:6379
# whether to use celery or not
# may also be a broker url like: redis://localhost:6379/0
# if set to "true", the broker url defaults to:
# redis://<redis_host>:<redis_port>/2
# where <redis_host> is the host part, and <redis_port> is the port part of
# the above "redis" setting
celery = false
# database url to store some persistent data
# none or a connect string supported by SQLAlchemy:
# http://docs.sqlalchemy.org/en/latest/core/engines.html#database-urls
# example: sqlite:////var/lib/burpui/store.db
database = none

[Experimental]
## This section contains some experimental features that have not been deeply
## tested yet
# enable zip64 feature. Python doc says:
# « ZIP64 extensions are disabled by default because the default zip and unzip
# commands on Unix (the InfoZIP utilities) don’t support these extensions. »
zip64 = false
noserverrestore = false

[Security]
## This section contains some security options. Make sure you understand the
## security implications before changing these.
# list of 'root' paths allowed when sourcing files in the configuration.
# Set this to 'none' if you don't want any restrictions, keeping in mind this
# can lead to accessing sensible files. Defaults to '/etc/burp'.
# Note: you can have several paths separated by comas.
# Example: /etc/burp,/etc/burp.d
includes = /etc/burp
# if files already included in config do not respect the above restriction, we
# prune them
enforce = true
# enable certificates revocation
revoke = true
# remember_cookie duration in days
cookietime = 14
# number of days of inactivity before invalidating a session (suppose your
# browser is open for days/months, your session will never expire, unless you
# set this to a positive value) # if set to 0 sessions will last forever
# Note: this requires the use of a database to work
sessiontime = 5
# whether to use a secure cookie for https or not. If set to false, cookies
# won't have the 'secure' flag.
# This setting is only useful when HTTPS is detected
scookie = true
# application secret to secure cookies. If you don't set anything, the default
# value is 'random' which will generate a new secret after every restart of your
# application. You can also set it to 'none' although this is not recommended.
appsecret = random

{% if BURP_ENV_BUI_AGENT_PASSWORD is defined %}
[Agent:burp]
# bui-agent address
host = burp
# bui-agent port
port = 10000
# bui-agent password
password = {{ BURP_ENV_BUI_AGENT_PASSWORD }}
# enable SSL
ssl = true
timeout = 0
{% endif %}
