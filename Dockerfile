FROM ubuntu:18.04

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

RUN mkdir -p /root/.ssh
RUN mkdir -p /root/netopeer2-all-build
RUN mkdir -p /run/sshd

COPY ./rbbn-id_rsa.pub     /root/.ssh/authorized_keys
COPY ./rbbn-id_rsa.pub     /root/.ssh/id_rsa.pub
COPY ./rbbn-id_rsa.pub.pem /root/.ssh/id_rsa.pub.pem
COPY ./rbbn-id_rsa         /root/.ssh/id_rsa
COPY ./netopeer2-all-build /root/netopeer2-all-build

RUN \
     chown -R  root:root /root/.ssh ; \
     chmod 700 /root/.ssh ; \
     chmod 664 /root/.ssh/authorized_keys; \
     chmod 600 /root/.ssh/id_rsa; \
     chmod 600 /root/.ssh/id_rsa.pub; \
     chmod 600 /root/.ssh/id_rsa.pub.pem

WORKDIR /root/netopeer2-all-build/
RUN ./ubuntu1804-prepare.sh


WORKDIR /root/netopeer2-all-build/
RUN ./build-all.sh

RUN groupadd --gid "$IGID" "$IGROUP" ;\
    useradd -s /bin/bash -m -G adm,sudo --gid "$IGID" --uid "$IUID" "$IUSER"; \
    echo "rbbn:Az!23456" | chpasswd ; \
    mkdir -p /home/rbbn/.ssh

COPY ./rbbn-id_rsa.pub     /home/rbbn/.ssh/authorized_keys
COPY ./rbbn-id_rsa.pub     /home/rbbn/.ssh/id_rsa.pub
COPY ./rbbn-id_rsa.pub.pem /home/rbbn/.ssh/id_rsa.pub.pem
COPY ./rbbn-id_rsa         /home/rbbn/.ssh/id_rsa

RUN \
     chown -R rbbn:rbbn /home/rbbn/.ssh ; \
     chmod 700 /home/rbbn/.ssh ; \
     chmod 664 /home/rbbn/.ssh/authorized_keys; \
     chmod 600 /home/rbbn/.ssh/id_rsa; \
     chmod 600 /home/rbbn/.ssh/id_rsa.pub; \
     chmod 600 /home/rbbn/.ssh/id_rsa.pub.pem


EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
#CMD ["/bin/bash"]
