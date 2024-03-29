########################################################################################################## 
# Dockerfile, based on https://github.com/CESNET/Netopeer2GUI/blob/v2/docker/demo/Dockerfile 
# 
FROM ubuntu:18.04 

SHELL ["/bin/bash", "-c"]
MAINTAINER ivor911@gmail.com

ENV APP_NAME=netconf-yang
ENV INSTALL_APP_DIR="/$APP_NAME"
ENV DEBIAN_FRONTEND noninteractive
ENV IUSER=rbbn
ENV IGROUP=rbbn
ENV IUID=12345
ENV IGID=12345
########################################################################################################## 
# create user and prepare keys
RUN mkdir -p /root/.ssh; \
	mkdir -p /root/.netopeer2-cli; \
	mkdir -p /run/sshd; \
	mkdir -p /root/netopeer2-all-build

COPY ./netopeer2-all-build /root/netopeer2-all-build
COPY ./netopeer2-all-build/.netopeer2-cli /root/.netopeer2-cli

RUN groupadd --gid "$IGID" "$IGROUP" ;\
    useradd -s /bin/bash -m -G adm,sudo --gid "$IGID" --uid "$IUID" "$IUSER"; \
    echo 'rbbn:Az!23456' | chpasswd ; \
    echo 'root:Az!23456' | chpasswd ; \
    mkdir -p /home/rbbn/.ssh ; \
	mkdir -p /home/rbbn/.netopeer2-cli
COPY ./netopeer2-all-build/.netopeer2-cli /home/rbbn/.netopeer2-cli

RUN \
	chown -R rbbn:rbbn /home/rbbn

WORKDIR /root/netopeer2-all-build/
########################################################################################################## 
# Install required binaries
RUN apt-get update -y && apt-get install -y \
	net-tools iproute2 vim wget iputils-ping tmux \
	openssh-server openssh-client net-tools debhelper rpm --assume-yes apt-utils

RUN apt-get update -y && apt-get install -y \
   mongodb python3 python3-dev python3-pip \
   pkg-config \
   git cmake clang curl \
   libpcre3-dev swig \
   zlib1g-dev libgcrypt-dev libssl-dev \
   libprotobuf-c-dev protobuf-c-compiler libavl-dev libev-dev \
   libffi-dev python3-setuptools nginx


# Install libssh from source (Version from apt is incompatible with libnetconf2)
#RUN tar xf /root/netopeer2-all-build/libssh.stable-0.8.tar.gz; cd libssh; mkdir build; cd build ;\
#   cmake ..; make; make install ; cd /
RUN git clone -b stable-0.8 http://git.libssh.org/projects/libssh.git ; cd libssh; mkdir build; cd build ;\
    cmake ..; make; make install ; cd /


########################################################################################################## 
#Build CESNET-NETCONF
WORKDIR /root/netopeer2-all-build/
RUN ./build-all.sh 2>&1 | tee --append build-all.LOG ;\
    cp build-all.LOG /build-all.LOG

########################################################################################################## 
# Copy import and ctrl files
RUN mkdir -p /import_files ; \
    mkdir -p /ctrl
COPY ./import_files                                    /import_files
COPY ./import_files/ihung_call-sr_get_items_example.sh /netconf-yang/sysrepo_examples
COPY ./import_files/ihung_monitor.sh                   /netconf-yang/sysrepo_examples
COPY ./ctrl                                            /ctrl
RUN cp -r /python_examples_NEW  /import_files/python_examples_NEW ;\
    cp -r /python_bindings      /import_files/python_bindings
RUN touch /root/.bashrc \
 && cat /import_files/bashrc.import >> /root/.bashrc \
 && cat /import_files/ihung_helper/vimrc.import >> /root/.vimrc \
 && cp -r /import_files/ihung_helper/vim /root/.vim \
 && cp /root/netopeer2-all-build/build-all.LOG /build-all.LOG

########################################################################################################## 
# setup netconf/yang
#COPY setup.sh "$INSTALL_APP_DIR"/bin/
#RUN bash "$INSTALL_APP_DIR"/bin/setup.sh "$INSTALL_APP_DIR"/bin/sysrepoctl /netconf-yang/yang root
RUN rm -fr /dev/shm/sr_* \ 
	&& rm -f  "$INSTALL_APP_DIR"/sr_main_lock \
	&& rm -f  "$INSTALL_APP_DIR"/sr_main_lock \
	&& rm -fr "$INSTALL_APP_DIR"/data \
	&& rm -fr "$INSTALL_APP_DIR"/yang \
	&& "$INSTALL_APP_DIR"/scripts/pre-setup.sh    "$INSTALL_APP_DIR"/ \
	&& "$INSTALL_APP_DIR"/scripts/load-default.sh "$INSTALL_APP_DIR"/ 



#CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]

########################################################################################################## 
# Inststall Netopeer2GUI
WORKDIR /
RUN "$INSTALL_APP_DIR"/scripts/Netopeer2GUI_install.sh 2>&1 | tee --append /Netopeer2GUI_install.sh.LOG
