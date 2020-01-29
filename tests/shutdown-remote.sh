docker stop rsync-server \
    && docker rm rsync-server \
    && docker stop test-sshd \
    && docker rm test-sshd \
    && docker stop test-sshd-rsyncd \
    && docker rm test-sshd-rsyncd \
    && rm docker-root* -v
