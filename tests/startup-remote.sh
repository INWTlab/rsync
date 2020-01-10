echo "starting rsync server"
docker run \
       --name rsync-server \
       -d \
       -p 8000:873 \
       -e USERNAME=user \
       -e PASSWORD=pass \
       axiom/rsync-server

echo "starting sshd in container"
docker run \
       -d \
       -p 20011:22 \
       --name test-sshd \
       rastasheep/ubuntu-sshd:18.04
ssh-keygen -f ./docker-root -C "" -N ""
docker cp ./docker-root.pub test-sshd:/root/.ssh/authorized_keys
docker exec test-sshd chown root:root /root/.ssh/authorized_keys
docker exec test-sshd apt-get update
docker exec test-sshd apt-get install -y rsync
