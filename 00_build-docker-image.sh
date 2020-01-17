#!/bin/sh
MYDOCKER_REPO="ihung-netopeer2"
MYTAG="icnteam-vswitch"
MYDOCKER_NAME="ihung-netopeer2"
docker build --rm --no-cache -t $MYDOCKER_REPO:$MYTAG . 
