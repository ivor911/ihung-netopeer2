#!/bin/bash
apt-get update
apt-get install -y sudo net-tools iproute2
apt-get install -y vim cmake libpcre3 libpcre3-dev doxygen doxygen-doc libdoxygen-filter-perl graphviz cmocka-doc libcmocka-dev libcmocka0 libgnutls28-dev libcurl4-openssl-dev valgrind tree groff libssl-dev libssl-doc libgnutls28-dev libgnutls-openssl27 automake libtool pkg-config build-essential ccache libboost-dev libboost-system-dev liblog4cplus-dev libssl-dev bison flex libavl-dev libev-dev libpcre3-dev libprotobuf-c-dev protobuf-c-compiler swig python3-dev libboost-all-dev git iputils-ping

# Install libssh from source (Version from apt is incompatible with libnetconf2)
git clone -b stable-0.8 http://git.libssh.org/projects/libssh.git
mkdir -p ./libssh/build
pushd ./libssh/build
cmake ..; make; make install 
popd

