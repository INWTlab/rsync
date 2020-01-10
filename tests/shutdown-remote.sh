docker stop rsync-server \
    && docker rm rsync-server \
    && docker stop test-sshd \
    && docker rm test-sshd \
    && rm docker-root* -v
