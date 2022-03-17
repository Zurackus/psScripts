#Splunk Docker Documenation
https://splunk.github.io/docker-splunk/

#Download the required Splunk Enterprise image to your local Docker image library
docker pull splunk/splunk:latest

#Run the downloaded Docker image
#SPLUNK_PASSWORD='<password>' parameter sets the login password for the 'admin' user
#-p <host_port>:<container_port>
docker run -d -p 8000:8000 -e SPLUNK_START_ARGS='--accept-license' -e SPLUNK_PASSWORD='<password>' splunk/splunk:latest
docker run -d -p 8000:8000 -e SPLUNK_START_ARGS='--accept-license' -e SPLUNK_PASSWORD='Zipper834$' splunk/splunk:latest

#You can verify the ports in use by running:
docker port <container_id>
docker port bb316ee5250b2ef8e40783e65c6b60aaa1cb11b60a11b5b

#Run the following command with the container ID to display the status of the container
docker ps -a -f id=<container_id>
docker ps -a -f id=bb316ee5250b2ef8e40783e65c6b60aaa1cb11b60a11b5b

#To verify the container ID, run below to review the container ID, status, and port mappings of all running containers
docker ps

#Open an web browser on the host and access SplunkWeb inside the container using the address
localhost:8000

#To see a list of example commands and environment variables for running Splunk Enterprise in a container, run:
docker run -it splunk/splunk help

#To see a list of your running containers, run:
docker ps

#To stop your Splunk Enterprise container, run:
docker container stop <container_id>

#To restart a stopped container, run:
docker container start <container_id>

#To access a running Splunk Enterprise container to perform administrative tasks, such as modifying configuration files, run:
docker exec -it <container_id> bash


