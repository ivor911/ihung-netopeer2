########################################################################################################## 
# intermediate docker image, we use it as builder.
FROM ubuntu:18.04 as intermediate

SHELL ["/bin/bash", "-c"]
MAINTAINER ivor911@gmail.com

ENV APP_NAME=netconf-yang
ENV INSTALL_APP_DIR="/$APP_NAME"
ENV DEBIAN_FRONTEND noninteractive
ENV IUSER=rbbn
ENV IGROUP=rbbn
ENV IUID=12345
ENV IGID=12345
# update system
RUN \
      apt-get update

RUN \
      apt-get -y install openssh-server openssh-client pkg-config net-tools debhelper rpm --assume-yes apt-utils


RUN mkdir -p /root/netopeer2-all-build
COPY ./netopeer2-all-build /root/netopeer2-all-build
WORKDIR /root/netopeer2-all-build/
RUN ./ubuntu1804-prepare.sh


WORKDIR /root/netopeer2-all-build/
RUN ./build-all.sh


########################################################################################################## 
# Real docker image
FROM ubuntu:18.04

SHELL ["/bin/bash", "-c"]
MAINTAINER ivor911@gmail.com
ENV APP_NAME=netconf-yang
ENV INSTALL_APP_DIR="/$APP_NAME"
ENV DEBIAN_FRONTEND noninteractive
ENV IUSER=rbbn
ENV IGROUP=rbbn
ENV IUID=22345
ENV IGID=22345

COPY --from=intermediate "$INSTALL_APP_DIR" "$INSTALL_APP_DIR"
COPY --from=intermediate /etc/ld.so.conf.d/ld-"$APP_NAME".conf /etc/ld.so.conf.d/ld-"$APP_NAME".conf
RUN ldconfig
RUN mkdir -p "$INSTALL_APP_DIR"/lib/sysrepo/plugins/

RUN apt-get update && apt-get install -y curl libprotobuf-c-dev libev-dev libavl-dev libssh-dev
RUN apt-get update && apt-get install -y supervisor

WORKDIR /

########################################################################################################## 
# create user and prepare keys
RUN mkdir -p /root/.ssh; \
	mkdir -p /root/.netopeer2-cli; \
	mkdir -p /run/sshd

COPY ./netopeer2-all-build/.netopeer2-cli /root/.netopeer2-cli
COPY ./keys/rbbn-id_rsa.pub     /root/.ssh/authorized_keys
COPY ./keys/rbbn-id_rsa.pub     /root/.ssh/id_rsa.pub
COPY ./keys/rbbn-id_rsa.pub.pem /root/.ssh/id_rsa.pub.pem
COPY ./keys/rbbn-id_rsa         /root/.ssh/id_rsa
RUN \
     chown -R  root:root /root/.ssh ; \
     chmod 700 /root/.ssh ; \
     chmod 664 /root/.ssh/authorized_keys; \
     chmod 600 /root/.ssh/id_rsa; \
     chmod 600 /root/.ssh/id_rsa.pub; \
     chmod 600 /root/.ssh/id_rsa.pub.pem

RUN groupadd --gid "$IGID" "$IGROUP" ;\
    useradd -s /bin/bash -m -G adm,sudo --gid "$IGID" --uid "$IUID" "$IUSER"; \
    echo "rbbn:Az!23456" | chpasswd ; \
    mkdir -p /home/rbbn/.ssh ; \
	mkdir -p /home/rbbn/.netopeer2-cli

COPY ./netopeer2-all-build/.netopeer2-cli /home/rbbn/.netopeer2-cli
COPY ./keys/rbbn-id_rsa.pub     /home/rbbn/.ssh/authorized_keys
COPY ./keys/rbbn-id_rsa.pub     /home/rbbn/.ssh/id_rsa.pub
COPY ./keys/rbbn-id_rsa.pub.pem /home/rbbn/.ssh/id_rsa.pub.pem
COPY ./keys/rbbn-id_rsa         /home/rbbn/.ssh/id_rsa

RUN \
     chown -R rbbn:rbbn /home/rbbn ; \
     chmod 700 /home/rbbn/.ssh ; \
     chmod 664 /home/rbbn/.ssh/authorized_keys; \
     chmod 600 /home/rbbn/.ssh/id_rsa; \
     chmod 600 /home/rbbn/.ssh/id_rsa.pub; \
     chmod 600 /home/rbbn/.ssh/id_rsa.pub.pem

########################################################################################################## 
# setup netconf/yang
#COPY setup.sh "$INSTALL_APP_DIR"/bin/
#RUN bash "$INSTALL_APP_DIR"/bin/setup.sh "$INSTALL_APP_DIR"/bin/sysrepoctl /netconf-yang/yang root
RUN bash "$INSTALL_APP_DIR"/bin/merge_hostkey.sh "$INSTALL_APP_DIR"/bin/sysrepocfg openssl
RUN bash "$INSTALL_APP_DIR"/bin/merge_config.sh  "$INSTALL_APP_DIR"/bin/sysrepocfg genkey

########################################################################################################## 
# Copy import and ctrl files
RUN mkdir -p /import_files ; \
    mkdir -p /ctrl
COPY ./import_files /import_files
COPY ./ctrl /ctrl
RUN touch /root/.bashrc \
 && cat /import_files/bashrc.import >> /root/.bashrc

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
#CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]

