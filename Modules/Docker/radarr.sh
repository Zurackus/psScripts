docker run -d \
    -p 7878:7878 \
    --name=radarr \
    -v /mnt/v/downloads/Media:/media \
    -v /mnt/v/downloads:/data \
    -v /apps/docker/radarr/config:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e UMASK=000 \
    -e PUID=1000 \
    -e PGID=1000 \
    binhex/arch-radarr
#Truepath365