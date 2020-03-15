# ihung-netopeer2:latest #

A netopeer2 images for x86_64
```
$ docker pull ivor911/ihung-netopeer2:latest
$ docker run -dit --privileged --net=host --hostname=ihung-netopeer2-docker --name ihung-netopeer2-docker ivor911/ihung-netopeer2:latest
$ docker exec -it ihung-netopeer2-docker /bin/bash
root@ihung-netopeer2-docker:/#

# Start netopeer2-server daemon after in docker
root@ihung-netopeer2-docker:# cd /import_files
root@ihung-netopeer2-docker:/import_files# ./start-netconf2.sh
```

# ihung-netopeer2:aarch64-latest #

A netopeer2 images for arm64
```
$ docker pull ivor911/ihung-netopeer2:aarch64-latest
$ docker run -dit --privileged --net=host --hostname=ihung-netopeer2-docker --name ihung-netopeer2-docker ivor911/ihung-netopeer2:aarch64-latest
$ docker exec -it ihung-netopeer2-docker /bin/bash
root@ihung-netopeer2-docker:/#

# Start netopeer2-server daemon after in docker
root@ihung-netopeer2-docker:# cd /import_files
root@ihung-netopeer2-docker:/import_files# ./start-netconf2.sh
```

# Build docker from github source #

./00_build-docker-image.sh x86_64

./00_build-docker-image.sh aarch64


# Run docker from github source after you build docker by yourself #

./01_run-and-exec-docker.sh

or ./02_run-and-exec-docker_priv-netHost.sh

# Start netopeer2-server daemon after go in docker #

root@ihung-netopeer2-docker:# cd /import_files
root@ihung-netopeer2-docker:/import_files# ./start-netconf2.sh

## netopeer2-server will listen on port 830 ##
