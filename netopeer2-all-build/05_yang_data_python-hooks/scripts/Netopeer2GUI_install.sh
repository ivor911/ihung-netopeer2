#!/bin/bash
set -x
#############################################################
# In rbbn
# su -l rbbn
# cd ~
# git clone https://github.com/CESNET/Netopeer2GUI.git

#############################################################
# In root

# tools
apt-get update
apt-get update ;apt-get install vim openssh-client less tree net-tools iproute2 iputils-ping tmux -y
apt-get install -y pkg-config git cmake clang libpcre3-dev python3-dev swig libssh-4 libssh-dev libssl-dev libssl-doc zlib1g-dev libprotobuf-c-dev protobuf-c-compiler libavl-dev libev-dev


# Already install NETCONF/YANG 4 packages?
ldconfig
if [ -z "${PKG_CONFIG_PATH}" ]; then
    export PKG_CONFIG_PATH="/netconf-yang/lib/pkgconfig"
else
    export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/netconf-yang/lib/pkgconfig"
fi

#tools_npm
# apt-get install -y python3-pip virtualenv nodejs npm
apt-get install -y python3-pip virtualenv nodejs libssl1.0-dev  nodejs-dev node-gyp npm

# if under docker
[ -f /.dockerenv ] && npm config set unsafe-perm true
npm install -g n
n stable
ln -fs /usr/local/bin/node /usr/bin/node
ln -fs /usr/local/bin/npm /usr/bin/npm
ln -fs /usr/local/bin/npx /usr/bin/npx
ln -fs /bin/bash /bin/sh


#liberoutergui 
cd /
rm -rf /liberouter-gui
rm -fr /Netopeer2GUI
#git clone https://github.com/CESNET/Netopeer2GUI.git
git clone https://github.com/ivor911/Netopeer2GUI.git
#git clone https://github.com/CESNET/liberouter-gui.git
git clone https://github.com/ivor911/liberouter-gui.git
ln -s /Netopeer2GUI /liberouter-gui/modules/netopeer
cd liberouter-gui
cp -f modules/netopeer/app.config.json modules/
python3 ./bootstrap.py
virtualenv venv --system-site-packages -p python3
source venv/bin/activate
pip3 install --upgrade pip
#pip3 install -r backend/requirements.txt
apt-get remove -y python3-wheel python3-cffi-backend
pip3 install -r backend/requirements.new.txt
deactivate
cd frontend
export NG_CLI_ANALYTICS=ci
npm install --unsafe-perm -g @angular/cli
npm install --unsafe-perm
cd ../..

# tools_ssl
apt-get install -y libssh-4 libssh-dev libssl-dev libssl-doc zlib1g-dev 

apt-get clean
# backend 
:<<'BACKEND'
cd /liberouter-gui
source venv/bin/activate
python3 backend > backend.log 2>&1 &
deactivate
cd ..
BACKEND

:<<'FRONTEND'
# frontend
cd /liberouter-gui/frontend
/usr/local/bin/ng serve --host 0.0.0.0 --proxy-config proxy.json > ../frontend.log 2>&1 &
cd ../..
FRONTEND

# start sysrepo/netopeer2-server


