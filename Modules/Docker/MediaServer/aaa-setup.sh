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
# Add the group to Admin user 'docker'
sudo usermod -a -G mediacenter docker

# Make arr users
sudo useradd sonarr -u 13001
sudo useradd radarr -u 13002
sudo useradd lidarr -u 13003
sudo useradd readarr -u 13004
sudo useradd prowlarr -u 13005
sudo useradd bazarr -u 13006
sudo useradd readarr-ab -u 13007
# Make plex users
sudo useradd plex -u 13011
sudo useradd tautulli -u 13012
sudo useradd overseer -u 13013
# Make downloader users
sudo useradd qbittorrent -u 13051
sudo useradd nzbget -u 13052
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
# Other Docker Users
sudo useradd watchtower -u 13021
sudo useradd heimdall -u 13022
sudo useradd traefik -u 13023
sudo useradd authelia -u 13024

# Make config directories
sudo mkdir -pv /media/docker/{plex,sonarr,radarr,lidarr,readarr,readarr-ab,prowlarr,qbittorrent,bazarr,nzbget,traefik,authelia,heimdall,tautulli,overseer,watchtower}-config

# Make the Media directories
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

# Set the read/write/execute to just owner/group
sudo chmod -R 770 /media/drive/data/
# Set group 'mediacenter' as the group for the Directory, switch $ for your admin user(docker)
sudo chown -R $:mediacenter /media/drive/data

# chown - set owner for config file
sudo chown -R sonarr /media/docker/sonarr-config
sudo chown -R radarr /media/docker/radarr-config
sudo chown -R lidarr /media/docker/lidarr-config
sudo chown -R readarr /media/docker/readarr-config
sudo chown -R readarr-ab /media/docker/readarr-ab-config
sudo chown -R prowlarr /media/docker/prowlarr-config
sudo chown -R bazarr /media/docker/bazarr-config

sudo chown -R plex /media/docker/plex-config
sudo chown -R tautulli /media/docker/tautulli-config
sudo chown -R overseer /media/docker/overseer-config

sudo chown -R qbittorrent /media/docker/qbittorrent-config
sudo chown -R nzbget /media/docker/nzbget-config

sudo chown -R watchtower /media/docker/watchtower-config
sudo chown -R heimdall /media/docker/heimdall-config
sudo chown -R traefik /media/docker/traefik-config
sudo chown -R authelia /media/docker/authelia-config