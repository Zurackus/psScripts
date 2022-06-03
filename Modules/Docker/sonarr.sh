#https://hub.docker.com/r/binhex/arch-sonarr
docker run -d \
    -p 8989:8989 \
    -p 9897:9897 \
    --name=<container name> \
    -v <path for media files>:/media \ #where ever you want to store your media
    -v <path for data files>:/data \ #same location as DelugeVPN location
    -v <path for config files>:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e UMASK=<umask for created files> \ #000
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    binhex/arch-sonarr