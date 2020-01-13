docker stop rsync-server \
    && docker rm rsync-server \
    && docker stop test-sshd \
    && docker rm test-sshd \
    && docker stop test-sshd-rsync \
    && docker rm test-sshd-rsync \
    && rm docker-root* -v
