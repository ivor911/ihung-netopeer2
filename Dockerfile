########################################################################################################## 
# intermediate docker image, we use it as builder.
FROM ubuntu:18.04 as intermediate

SHELL ["/bin/bash", "-c"]
MAINTAINER ivor911@gmail.com
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
ENV DEBIAN_FRONTEND noninteractive
ENV IUSER=rbbn
ENV IGROUP=rbbn
ENV IUID=22345
ENV IGID=22345

COPY --from=intermediate /hicn-root /hicn-root
COPY --from=intermediate /etc/ld.so.conf.d/hicn-root.conf /etc/ld.so.conf.d/hicn-root.conf
RUN ldconfig
RUN mkdir -p /hicn-root/lib/sysrepo/plugins/
#COPY --from=intermediate /hicn-build/sysrepo/  /hicn-build/sysrepo/
#COPY --from=intermediate /hicn-build/hicn  /hicn-build/hicn

RUN apt-get update && apt-get install -y curl libprotobuf-c-dev libev-dev libavl-dev libssh-dev
#RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash
#RUN apt-get update && apt-get install -y supervisor vpp libvppinfra vpp-plugin-core vpp-dev libhicn-dev
RUN apt-get update && apt-get install -y supervisor

WORKDIR /
COPY 02_setup.sh /
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

########################################################################################################## 
# create user and prepare keys
RUN mkdir -p /root/.ssh; \
	mkdir -p /root/.netopeer2-cli; \
	mkdir -p /run/sshd

COPY ./netopeer2-all-build/.netopeer2-cli /root/.netopeer2-cli
COPY ./rbbn-id_rsa.pub     /root/.ssh/authorized_keys
COPY ./rbbn-id_rsa.pub     /root/.ssh/id_rsa.pub
COPY ./rbbn-id_rsa.pub.pem /root/.ssh/id_rsa.pub.pem
COPY ./rbbn-id_rsa         /root/.ssh/id_rsa
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
COPY ./rbbn-id_rsa.pub     /home/rbbn/.ssh/authorized_keys
COPY ./rbbn-id_rsa.pub     /home/rbbn/.ssh/id_rsa.pub
COPY ./rbbn-id_rsa.pub.pem /home/rbbn/.ssh/id_rsa.pub.pem
COPY ./rbbn-id_rsa         /home/rbbn/.ssh/id_rsa

RUN \
     chown -R rbbn:rbbn /home/rbbn ; \
     chmod 700 /home/rbbn/.ssh ; \
     chmod 664 /home/rbbn/.ssh/authorized_keys; \
     chmod 600 /home/rbbn/.ssh/id_rsa; \
     chmod 600 /home/rbbn/.ssh/id_rsa.pub; \
     chmod 600 /home/rbbn/.ssh/id_rsa.pub.pem

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]

