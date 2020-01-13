#!/bin/bash
# This file uses the config inside the container: axiom/rsync-server

set -e

USERNAME=${USERNAME:-user}
PASSWORD=${PASSWORD:-pass}
ALLOW=${ALLOW:-127.0.0.1/32}
VOLUME=${VOLUME:-/data}

if [ "$1" = 'rsync_server' ]; then

    echo "$USERNAME:$PASSWORD" > /etc/rsyncd.secrets
    chmod 0400 /etc/rsyncd.secrets

    mkdir -p $VOLUME

    [ -f /etc/rsyncd.conf ] || cat <<EOF > /etc/rsyncd.conf
    pid file = /var/run/rsyncd.pid
    log file = /var/log/rsyncd.log
    timeout = 300
    max connections = 10
    port = 873
    #reverse lookup = no

    [volume]
        uid = root
        gid = root
        hosts deny = *
        hosts allow = ${ALLOW}
        read only = false
        path = ${VOLUME}
        comment = ${VOLUME} directory
        auth users = ${USERNAME}
        secrets file = /etc/rsyncd.secrets
EOF

    exec /usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf "$@" &
fi
