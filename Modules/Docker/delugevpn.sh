#https://hub.docker.com/r/binhex/arch-delugevpn/
docker run -d \
    --cap-add=NET_ADMIN \
    -p 8112:8112 \
    -p 8118:8118 \
    -p 58846:58846 \
    -p 58946:58946 \
    #--name=<container name> \
    #-v <path for data files>:/data \ Share\downloads
    #-v <path for config files>:/config \
    #-v /etc/localtime:/etc/localtime:ro \
    -e VPN_ENABLED=<yes|no> \ #yes
    -e VPN_USER=<vpn username> \ #Service user
    -e VPN_PASS=<vpn password> \ #Service password
    #-e VPN_PROV=<pia|airvpn|custom> \  Custom
    -e VPN_CLIENT=<openvpn|wireguard> \ #OpenVPN
    -e VPN_OPTIONS=<additional openvpn cli options> \ #None
    -e STRICT_PORT_FORWARD=yes \ #yes
    -e ENABLE_PRIVOXY=<yes|no> \ #no
    -e LAN_NETWORK=<lan ipv4 network>/<cidr notation> \ #local Lan where the container is running
    -e NAME_SERVERS=<name server ip(s)> \
    -e DELUGE_DAEMON_LOG_LEVEL=<info|warning|error|none|debug|trace|garbage> \ #info
    -e DELUGE_WEB_LOG_LEVEL=<info|warning|error|none|debug|trace|garbage> \ #info
    -e VPN_INPUT_PORTS=<port number(s)> \
    -e VPN_OUTPUT_PORTS=<port number(s)> \
    -e DEBUG=<true|false> \
    -e UMASK=<umask for created files> \
    -e PUID=<UID for user> \
    -e PGID=<GID for user> \
    binhex/arch-delugevpn