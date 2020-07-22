# Build docker image from github source #
```
./01_run-and-exec-docker.sh

or ./02_run-and-exec-docker_priv-netHost.sh

# docker root password is "Az!23456"
root@ihung-netopeer2-docker:/#

# Start netopeer2-server daemon in docker
root@ihung-netopeer2-docker:# /netconf-yang/scripts/start-netconf2.sh
# Then run command, 'netstat -tlunp | grep 830' to check netopeer2-server listen on port 830

# Start Netopeer2GUI in docker
root@ihung-netopeer2-docker:# /netconf-yang/scripts/start-Netopeer2GUI.sh
# Then run command, 'netstat -tlunp | grep 4200' to check ng serve(web froentend) listen on port 4200
# Then run command, 'netstat -tlunp | grep 5555' to check python3(web backend)  listen on port 830

# Then open your browser and access http://[Your Docker IP]:4200
```

# Run docker image: ihung-netopeer2:latest #

Run netopeer2 docker image on x86_64
```
$ docker pull ivor911/ihung-netopeer2:latest
$ docker run -dit --privileged --net=host --hostname=ihung-netopeer2-docker --name ihung-netopeer2-docker ivor911/ihung-netopeer2:latest
$ docker exec -it ihung-netopeer2-docker /bin/bash

# docker root password is "Az!23456"
root@ihung-netopeer2-docker:/#

# Start netopeer2-server daemon in docker
root@ihung-netopeer2-docker:# /netconf-yang/scripts/start-netconf2.sh
# Then run command, 'netstat -tlunp | grep 830' to check netopeer2-server listen on port 830

# Start Netopeer2GUI in docker
root@ihung-netopeer2-docker:# /netconf-yang/scripts/start-Netopeer2GUI.sh
# Then run command, 'netstat -tlunp | grep 4200' to check ng serve(web froentend) listen on port 4200
# Then run command, 'netstat -tlunp | grep 5555' to check python3(web backend)  listen on port 830

# Then open your browser and access http://[Your Docker IP]:4200
```

# Run docker image: ihung-netopeer2:aarch64-latest #

Run netopeer2 docker image on arm64
```
$ docker pull ivor911/ihung-netopeer2:aarch64-latest
$ docker run -dit --privileged --net=host --hostname=ihung-netopeer2-docker --name ihung-netopeer2-docker ivor911/ihung-netopeer2:aarch64-latest
$ docker exec -it ihung-netopeer2-docker /bin/bash

# docker root password is "Az!23456"
root@ihung-netopeer2-docker:/#

# Start netopeer2-server daemon in docker
root@ihung-netopeer2-docker:# /netconf-yang/scripts/start-netconf2.sh
# Then run command, 'netstat -tlunp | grep 830' to check netopeer2-server listen on port 830

# Start Netopeer2GUI in docker
root@ihung-netopeer2-docker:# /netconf-yang/scripts/start-Netopeer2GUI.sh
# Then run command, 'netstat -tlunp | grep 4200' to check ng serve(web froentend) listen on port 4200
# Then run command, 'netstat -tlunp | grep 5555' to check python3(web backend)  listen on port 830

# Then open your browser and access http://[Your Docker IP]:4200
```

# Build docker from github source #

./00_build-docker-image.sh x86_64

./00_build-docker-image.sh aarch64


