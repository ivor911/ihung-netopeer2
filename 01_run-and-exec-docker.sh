#!/bin/sh
MYDOCKER_REPO="ihung-netopeer2"
#MYTAG=`git branch | grep \* | cut -d ' ' -f2-`
#I_ARCH="$1"
I_ARCH="`uname -m`"
MYTAG="${I_ARCH}"
MYDOCKER_NAME="ihung-netopeer2"
MYDOCKER_NAME="ihung-netopeer2"
MYDOCKER_HOSTNAME="ihung-np2-docker-"

case "$I_ARCH" in
    x86_64)
        MYTAG="latest"
        ;;
    aarch64)
        MYTAG="aarch64-latest"
        ;;
    *)
        echo "ERROR: We only support below architecture types."
        echo "usage:"
        echo "        $0 x86_64"
        echo "        $0 aarch64"
        exit 1
        ;;
esac

#docker run -e AUTHORIZED_KEYS=/root/.ssh/authorized_keys -dit --publish 22222:22 --name $MYDOCKER  $MYDOCKER:latest
docker run -dit --publish 830:830 --hostname=$MYDOCKER_HOSTNAME --name $MYDOCKER_NAME  $MYDOCKER_REPO:$MYTAG
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



