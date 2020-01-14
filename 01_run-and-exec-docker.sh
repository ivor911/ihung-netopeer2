#!/bin/sh
MYDOCKER="ihung-netopeer2"
#docker run -e AUTHORIZED_KEYS=/root/.ssh/authorized_keys -dit --publish 22222:22 --name $MYDOCKER  $MYDOCKER:latest
docker run -dit --publish 830:830 --name $MYDOCKER  $MYDOCKER:latest
docker exec -it $MYDOCKER /bin/bash

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



