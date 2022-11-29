#Labels to be added for dockers to be exposed
#Ports can be removed if these are added
    labels:
      - "traefik.enable=true" #Tells Traefik to expose this docker
      - "traefik.http.routers.portainer.entrypoints=http"
      - "traefik.http.routers.portainer.rule=Host(`portainer.local.krpros.org`)" #host rule
      - "traefik.http.middlewares.portainer-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.routers.portainer.middlewares=portainer-https-redirect"
      - "traefik.http.routers.portainer.middlewares=authelia@docker" #label required for Authelia Authentication
      - "traefik.http.routers.portainer-secure.entrypoints=https"
      - "traefik.http.routers.portainer-secure.rule=Host(`portainer.local.krpros.org`)" #host rule
      - "traefik.http.routers.portainer-secure.tls=true"
      - "traefik.http.routers.portainer-secure.service=portainer"
      - "traefik.http.services.portainer.loadbalancer.server.port=9000" #port 9000 is portainers port
      - "traefik.docker.network=proxy"

networks:
  proxy:
    external: true

#Simple service notes
http:
 #region routers 
  routers: #incoming requests
    proxmox: #name of the service
      entryPoints:
        - "https"
      rule: "Host(`proxmox.local.krpros.org`)" #pointing to reverse proxy
      middlewares:
        - default-headers
      tls: {}
      service: proxmox

#endregion
#region services
  services:
    proxmox:
      loadBalancer:
        servers:
          - url: "https://192.168.0.100:8006" #Local IP address/port that the service is on
                                              #But you can use a local DNS name as well
        passHostHeader: true

#endregion
  middlewares:
    https-redirect:     # 
      redirectScheme:   # Automatically redirect everything to https
        scheme: https   #

    default-headers: #Proxmox
      headers:
        frameDeny: true
        sslRedirect: true
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 15552000
        customFrameOptionsValue: SAMEORIGIN
        customRequestHeaders:
          X-Forwarded-Proto: https

    default-whitelist: #Whitelist of the IP's that traefic will work with
      ipWhiteList:
        sourceRange:
        - "10.0.0.0/8"
        - "192.168.0.0/16"
        - "172.16.0.0/12"

    secured:
      chain:
        middlewares:
        - default-whitelist
        - default-headers

entryPoints:
  # Not used in apps, but redirect everything from HTTP to HTTPS
  http:
    address: :80
    forwardedHeaders:
      trustedIPs: &trustedIps
        # Start of Clouflare public IP list for HTTP requests, remove this if you don't use it
        - 173.245.48.0/20
        - 103.21.244.0/22
        - 103.22.200.0/22
        - 103.31.4.0/22
        - 141.101.64.0/18
        - 108.162.192.0/18
        - 190.93.240.0/20
        - 188.114.96.0/20
        - 197.234.240.0/22
        - 198.41.128.0/17
        - 162.158.0.0/15
        - 104.16.0.0/12
        - 172.64.0.0/13
        - 131.0.72.0/22
        - 2400:cb00::/32
        - 2606:4700::/32
        - 2803:f800::/32
        - 2405:b500::/32
        - 2405:8100::/32
        - 2a06:98c0::/29
        - 2c0f:f248::/32
        # End of Cloudlare public IP list
    http:
      redirections:
        entryPoint:
          to: https
          scheme: https

  # HTTPS endpoint, with domain wildcard
  https:
    address: :443
    forwardedHeaders:
      # Reuse list of Cloudflare Trusted IP's above for HTTPS requests
      trustedIPs: *trustedIps
    http:
      tls:
        # Generate a wildcard domain certificate
        certResolver: letsencrypt
        domains:
          - main: YOURDOMAIN.COM
            sans:
              - '*.YOURDOMAIN.COM'
      middlewares:
        - securityHeaders@file