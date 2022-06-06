#https://hub.docker.com/r/binhex/arch-prowlarr
docker run -d \
    -p 9696:9696 \
    --name=prowlarr \ #prowlarrd
    -v /apps/docker/prowlarr/config:/config \ #standard location
    -v /etc/localtime:/etc/localtime:ro \ 
    -e UMASK=000 \ #000
    -e PUID=1000 \
    -e PGID=1000 \
    binhex/arch-prowlarr