#Port 8000: used to communicate with Portainer Agents
#Port 9443: used to connect to portainer https://'hostip':9443
#TLS Portainer setup: https://docs.docker.com/engine/security/protect-access/
sudo mkdir -pv /media/docker/portainer-config
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /media/docker/portainer-config:/data portainer/portainer-ce:latest