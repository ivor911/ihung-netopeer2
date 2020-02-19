# ihung-netopeer2:yang-port
A exercise build for complete netopeer2 in docker.

yang-port branch is prepared for our YANG modules develop.

# Build docker:

./00_build-docker-image.sh

# Run docker:

./01_run-and-exec-docker.sh

or  ./02_run-and-exec-docker_priv-netHost.sh


# Start netopeer2-server daemon after go in netconf/yang docker

cd /import_files

./start-netconf2.sh
