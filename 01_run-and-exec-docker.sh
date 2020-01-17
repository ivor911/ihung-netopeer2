#!/bin/sh
MYDOCKER_REPO="ihung-netopeer2"
MYTAG="icnteam-vswitch"
MYDOCKER_NAME="ihung-netopeer2"
#docker run -e AUTHORIZED_KEYS=/root/.ssh/authorized_keys -dit --publish 22222:22 --name $MYDOCKER  $MYDOCKER:latest
docker run -dit --publish 830:830 --name $MYDOCKER_NAME  $MYDOCKER_REPO:$MYTAG
#or
#docker run -dit --publish 830:830 --name ihung-netopeer2 ivor911/ihung-netopeer2:latest
docker exec -it $MYDOCKER_NAME /bin/bash

#######################################################################
# After in docker, run:
# root@c89b41fecc1d:~/netopeer2-all-build# netopeer2-server -d -v 2
#######################################################################
# In another docker shell, run:
# root@c89b41fecc1d:~/netopeer2-all-build# netopeer2-cli
# > auth pref
# > auth pref password 0
# > auth pref interactive 0
# > auth keys
# > auth keys add /root/.ssh/id_rsa.pub /root/.ssh/id_rsa
# > connect



