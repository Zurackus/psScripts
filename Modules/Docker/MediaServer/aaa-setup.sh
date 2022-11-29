#!/bin/bash
## docker rule (host:Container)
# Sonarr    - 8989 
# Radarr    - 7878
# Lidarr    - 8686
# Readarr   - 8787
# Prowlarr  - 9696
# Bazarr    - 6767
# qbittorrent - 6881
# nzbget    - 6789
# traefik   - 80:8080/443:8443
# authelia  - 9091
# heimdall  - 443
# Tautulli  - 8181
# Overseer  - 5055
# Plex - 

# Make group
sudo groupadd mediacenter -g 13000
# Make arr users
sudo useradd sonarr -u 13001
sudo useradd radarr -u 13002
sudo useradd lidarr -u 13003
sudo useradd readarr -u 13004
sudo useradd prowlarr -u 13005
sudo useradd bazarr -u 13006
sudo useradd readarr-ab -u 13007
# Make downloader users
sudo useradd qbittorrent -u 13051
sudo useradd nzbget -u 13052
# Make plex users
sudo useradd plex -u 13031
sudo useradd tautulli -u 13032
sudo useradd overseer -u 13033
# Associate users with the group
sudo usermod -a -G mediacenter sonarr
sudo usermod -a -G mediacenter radarr
sudo usermod -a -G mediacenter lidarr
sudo usermod -a -G mediacenter readarr
sudo usermod -a -G mediacenter readarr-ab
sudo usermod -a -G mediacenter prowlarr
sudo usermod -a -G mediacenter bazarr
sudo usermod -a -G mediacenter qbittorrent
sudo usermod -a -G mediacenter nzbget
sudo usermod -a -G mediacenter plex
sudo usermod -a -G mediacenter tautulli
sudo usermod -a -G mediacenter overseer

# Make directories
sudo mkdir -pv /media/docker/{plex,sonarr,radarr,lidarr,readarr,readarr-ab,prowlarr,qbittorrent,bazarr,nzbget,traefik,authelia,heimdall,tautulli,overseer}-config

sudo mkdir -pv /media/docker/{shared}
sudo mkdir -pv /media/drive/data/{torrents,usenet,media}/{tv,movies,music,books}
### Folder Structure ###
#  data
#   ├──torrents
#   │  ├── movies
#   │  ├── music
#   |  ├── books
#   │  └── tv
#   ├──usenet
#   │  ├── movies
#   │  ├── music
#   │  ├── books
#   │  └── tv
#   └──media
#       ├── movies
#       ├── music
#       ├── books
#       └── tv


# Set permissions
# -R Recursively push the permissions to all files below
# https://chmodcommand.com/chmod-775/
# https://chmodcommand.com/chmod-755/ 
#sudo chown -R $(id -u):mediacenter /media/drive/data/

sudo chmod -R 775 /media/drive/data/

sudo chown -R sonarr:mediacenter /media/docker/sonarr-config
sudo chown -R radarr:mediacenter /media/docker/radarr-config
sudo chown -R lidarr:mediacenter /media/docker/lidarr-config
sudo chown -R readarr:mediacenter /media/docker/readarr-config
sudo chown -R readarr-ab:mediacenter /media/docker/readarr-ab-config
sudo chown -R prowlarr:mediacenter /media/docker/prowlarr-config
sudo chown -R bazarr:mediacenter /media/docker/bazarr-config

sudo chown -R qbittorrent:mediacenter /media/docker/qbittorrent-config
sudo chown -R nzbget:mediacenter /media/docker/nzbget-config

sudo chown -R plex:mediacenter /media/docker/plex-config
sudo chown -R tautulli:mediacenter /media/docker/tautulli-config
sudo chown -R overseer:mediacenter /media/docker/overseer-config
#sudo chown -R plex:mediacenter /media/drive/data/

#echo "UID=$(id -u)" >> .env