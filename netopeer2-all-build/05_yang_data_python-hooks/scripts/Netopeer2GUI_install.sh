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
apt-get update -y
apt-get install -y vim openssh-client less tree net-tools iproute2 iputils-ping tmux
apt-get install -y mongodb python3 python3-dev python3-pip
apt-get install -y pkg-config
apt-get install -y git cmake clang curl
apt-get install -y libpcre3-dev swig
apt-get install -y zlib1g-dev libgcrypt-dev libssl-dev
apt-get install -y libprotobuf-c-dev protobuf-c-compiler libavl-dev libev-dev
apt-get install -y libffi-dev python3-setuptools nginx


# Install libssh from source (Version from apt is incompatible with libnetconf2)
apt-get remove libssh-4 libssh-dev libssh-doc -y

#git clone -b stable-0.8 http://git.libssh.org/projects/libssh.git
#mkdir -p ./libssh/build
#pushd ./libssh/build
#cmake ..; make; make install
#popd

# Already install NETCONF/YANG 4 packages?
ldconfig
if [ -z "${PKG_CONFIG_PATH}" ]; then
    export PKG_CONFIG_PATH="/netconf-yang/lib/pkgconfig"
else
    export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/netconf-yang/lib/pkgconfig"
fi

#tools_npm
# apt-get install -y python3-pip virtualenv nodejs npm
apt-get install -y python3-pip virtualenv nodejs libssl1.0-dev  nodejs-dev node-gyp npm build-essential

# if under docker
[ -f /.dockerenv ] && npm config set unsafe-perm true
npm install -g n
#n stable
n install 12.18.4
ln -fs /usr/local/bin/node /usr/bin/node
ln -fs /usr/local/bin/npm /usr/bin/npm
ln -fs /usr/local/bin/npx /usr/bin/npx
ln -fs /bin/bash /bin/sh


# Prepare GUI 
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

# vim backend/liberouterapi/configurator.py
#import configparser
#sed -i 's/from backports //' backend/liberouterapi/configurator.py
cat > backend/requirements.fixed.txt << EOF
asn1crypto==0.24.0
bcrypt==3.1.7
certifi==2020.6.20
cffi==1.14.0
chardet==3.0.4
click==7.1.2
configparser==5.0.0
cryptography==2.1.4
dnspython==2.0.0
eventlet==0.25.2
Flask==1.1.2
Flask-SocketIO==4.3.0
greenlet==0.4.16
idna==2.6
itsdangerous==1.1.0
Jinja2==2.11.2
keyring==10.6.0
keyrings.alt==3.0
MarkupSafe==1.1.1
monotonic==1.5
netconf2==1.1.46
pip==20.1.1
pkg-resources==0.0.0
pycparser==2.20
pycrypto==2.6.1
pygobject==3.26.1
pymongo==3.10.1
python-engineio==3.13.1
python-pam==1.8.4
python-socketio==4.6.0
pyxdg==0.25
PyYAML==5.3.1
requests==2.24.0
SecretStorage==2.3.1
setuptools==49.2.0
six==1.15.0
urllib3==1.25.10
virtualenv==15.1.0
Werkzeug==1.0.1
wheel==0.34.2
EOF

python3 ./bootstrap.py
virtualenv venv --system-site-packages -p python3
source venv/bin/activate
pip3 install --upgrade pip
#pip3 install -r backend/requirements.txt
apt-get remove -y python3-wheel python3-cffi-backend
#pip3 install -r backend/requirements.new.txt
pip3 install -r backend/requirements.fixed.txt
deactivate

cd frontend
export NG_CLI_ANALYTICS=ci
npm cache verify
npm install --unsafe-perm -g @angular/cli@10.0.4
npm install --unsafe-perm
cd ../..

# tools_ssl
#apt-get install -y libssl-dev libssl-doc zlib1g-dev 
apt-get remove libssh-4 -y

apt-get clean
apt-get autoremove -y 
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


