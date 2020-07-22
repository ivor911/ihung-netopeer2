#!/bin/sh
echo "##################################################" > "$0.LOG"
echo "$0 $1. START time: " >> "$0.LOG"
date >> "$0.LOG"
echo "##################################################" >> "$0.LOG"

MYDOCKER_REPO="ihung-netopeer2"
#MYTAG=`git branch | grep \* | cut -d ' ' -f2-`
I_ARCH="$1"
#I_ARCH="`uname -m`"
MYTAG="${I_ARCH}"
MYDOCKER_NAME="ihung-netopeer2"

if [ "$I_ARCH" = "" ]; then
    echo "ERROR: You must give machine architecture specific."
    echo "usage:"
    echo "        $0 x86_64"
    echo "        $0 aarch64"
    exit 1
fi

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

docker build --rm --no-cache -t $MYDOCKER_REPO:$MYTAG . 2>&1 | tee --append "$0.LOG"

echo "##################################################" >> "$0.LOG"
echo "$0 $1. END time: " >> "$0.LOG"
date >> "$0.LOG"
echo "##################################################" >> "$0.LOG"
