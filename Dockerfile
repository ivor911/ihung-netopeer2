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
#RUN ./build-all.sh
RUN ./build-all.sh 2>&1 | tee --append build-all.LOG



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

RUN apt-get update && apt-get install -y curl libprotobuf-c-dev libev-dev libavl-dev libssh-dev python python-pip python3 python3-pip
RUN apt-get update && apt-get install -y supervisor
RUN apt-get update && apt-get install -y vim openssh-client less tree net-tools iproute2 iputils-ping tmux

COPY --from=intermediate "$INSTALL_APP_DIR"                         "$INSTALL_APP_DIR"
COPY --from=intermediate /usr/lib/python3/dist-packages/_yang.so                 /usr/lib/python3/dist-packages/
COPY --from=intermediate /usr/lib/python3/dist-packages/yang.py                  /usr/lib/python3/dist-packages/
COPY --from=intermediate /usr/lib/python3/dist-packages/_sysrepo.so              /usr/lib/python3/dist-packages/
COPY --from=intermediate /usr/lib/python3/dist-packages/sysrepo.py               /usr/lib/python3/dist-packages/
#netconf2.cpython-36m-x86_64-linux-gnu.so
COPY --from=intermediate /usr/lib/python3/dist-packages/netconf2.cpython*.so     /usr/lib/python3/dist-packages/
#netconf2-1.1.3.egg-info or netconf2-1.1.7.egg-info
COPY --from=intermediate /usr/lib/python3/dist-packages/netconf2-*.egg-info      /usr/lib/python3/dist-packages/
COPY --from=intermediate /etc/ld.so.conf.d/ld-"$APP_NAME".conf                   /etc/ld.so.conf.d/ld-"$APP_NAME".conf
RUN ldconfig
RUN mkdir -p "$INSTALL_APP_DIR"/lib/sysrepo/plugins/


WORKDIR /

########################################################################################################## 
# create user and prepare keys
RUN mkdir -p /root/.ssh; \
	mkdir -p /root/.netopeer2-cli; \
	mkdir -p /run/sshd

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

########################################################################################################## 
# setup netconf/yang
#COPY setup.sh "$INSTALL_APP_DIR"/bin/
#RUN bash "$INSTALL_APP_DIR"/bin/setup.sh "$INSTALL_APP_DIR"/bin/sysrepoctl /netconf-yang/yang root
RUN rm -fr /dev/shm/sr_*
RUN rm -f  "$INSTALL_APP_DIR"/sr_main_lock
RUN rm -fr "$INSTALL_APP_DIR"/data
RUN rm -fr "$INSTALL_APP_DIR"/yang
RUN "$INSTALL_APP_DIR"/scripts/pre-setup.sh    "$INSTALL_APP_DIR"/
RUN "$INSTALL_APP_DIR"/scripts/load-default.sh "$INSTALL_APP_DIR"/
#RUN "$INSTALL_APP_DIR"/bin/sysrepocfg -C startup -d running -m rbbn-nos-host

########################################################################################################## 
# Copy import and ctrl files
RUN mkdir -p /import_files ; \
    mkdir -p /ctrl
COPY ./import_files                                    /import_files
COPY ./import_files/ihung_call-sr_get_items_example.sh /netconf-yang/sysrepo_examples
COPY ./import_files/ihung_monitor.sh                   /netconf-yang/sysrepo_examples
COPY ./ctrl                                            /ctrl
COPY --from=intermediate /python_examples_NEW  /import_files/python_examples_NEW
COPY --from=intermediate /python_bindings      /import_files/python_bindings
RUN touch /root/.bashrc \
 && cat /import_files/bashrc.import >> /root/.bashrc \
 && cat /import_files/ihung_helper/vimrc.import >> /root/.vimrc \
 && cp -r /import_files/ihung_helper/vim /root/.vim

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY --from=intermediate /root/netopeer2-all-build/build-all.LOG /build-all.LOG
#CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]

### for develop
RUN "$INSTALL_APP_DIR"/scripts/Netopeer2GUI_install.sh
