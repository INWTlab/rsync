echo "starting rsync server"
docker run \
       --name rsync-server \
       -p 8000:873 \
       -e USERNAME=user \
       -e PASSWORD=pass \
       axiom/rsync-server

sleep 10
echo "stopping rsync server"
docker stop rsync-server && docker rm rsync-server
