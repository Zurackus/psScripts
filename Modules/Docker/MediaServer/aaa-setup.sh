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
sudo mkdir -pv docker/{plex,sonarr,radarr,lidarr,readarr,prowlarr,qbittorrent,bazarr,nzbget,tautulli,overseer}-config
sudo mkdir -pv docker/{watchtower,heimdall,traefik,authelia}-config
#traefik,authelia,heimdall

# Make the Media directories
sudo mkdir -pv data/{torrents/{movies,music,books,audiobooks,tv},usenet/{incomplete,complete/{movies,music,books,audiobooks,tv}},media/{movies,music,books,audiobooks,tv}}
### Folder Structure ###
#  data
#   ├──torrents
#   │  ├── movies
#   │  ├── music
#   |  ├── books
#   |  ├── audiobooks
#   │  └── tv
#   ├──usenet
#   │  ├── incomplete
#   │  └── complete
#   │       ├── movies
#   │       ├── music
#   │       ├── books
#   |       ├── audiobooks
#   │       └── tv
#   └──media
#       ├── movies
#       ├── music
#       ├── books
#       |── audiobooks
#       └── tv

# Set permissions
# -R Recursively push the permissions to all files below
# https://chmodcommand.com/chmod-775/

### 775 Permissions ###
# Set the read/write/execute to just owner/group
# Owner: Read, write, and execute permissions.
# Group: Read, write, and execute permissions.
# Others: Read and execute permissions.
sudo chmod -R 775 data
sudo find data ! -path "data/#recycle" -type d -exec chmod 775 {} +
# Set group 'mediacenter' as the group for the Directory, switch $ for your admin user(docker)
sudo chown -R docker:mediacenter data

# chown - set owner for config file
sudo chown -R sonarr docker/sonarr-config
sudo chown -R radarr docker/radarr-config
sudo chown -R lidarr docker/lidarr-config
sudo chown -R readarr docker/readarr-config
sudo chown -R readarr-ab docker/readarr-ab-config
sudo chown -R prowlarr docker/prowlarr-config
sudo chown -R bazarr docker/bazarr-config

sudo chown -R plex docker/plex-config
sudo chown -R tautulli docker/tautulli-config
sudo chown -R overseer docker/overseer-config

sudo chown -R qbittorrent docker/qbittorrent-config
sudo chown -R nzbget docker/nzbget-config

sudo chown -R watchtower docker/watchtower-config
sudo chown -R heimdall docker/heimdall-config
sudo chown -R traefik docker/traefik-config
sudo chown -R authelia docker/authelia-config

