#https://hub.docker.com/r/binhex/arch-prowlarr
docker run -d \
    -p 9696:9696 \
    --name=<container name> \ #prowlarrd
    -v <path for config files>:/config \ #standard location
    -v /etc/localtime:/etc/localtime:ro \ 
    -e UMASK=<umask for created files> \ #000
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    binhex/arch-prowlarr