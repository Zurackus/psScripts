#PiHole Configuration setup
docker run -d --name=pihole -e ServerIP=192.168.1.15 -e WEBPASSWORD=Whatcanido365# -e TZ=American/Los_Angeles -e DNS1=127.0.0.1 -e DNS2=1.1.1.1 -p 80:80 -p 53000:53/tcp -p 53000:53/udp -p 443:443 --restart=unless-stopped pihole/pihole:latest

