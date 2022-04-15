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


RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && apt-get install -y nodejs

# Install libssh from source (Version from apt is incompatible with libnetconf2)
#RUN tar xf /root/netopeer2-all-build/libssh.stable-0.8.tar.gz; cd libssh; mkdir build; cd build ;\
#   cmake ..; make; make install ; cd /
RUN git clone -b stable-0.8 http://git.libssh.org/projects/libssh.git ; cd libssh; mkdir build; cd build ;\
    cmake ..; make; make install ; cd /


########################################################################################################## 
#Build CESNET-NETCONF
WORKDIR /root/netopeer2-all-build/
RUN ./build-all.sh 2>&1 | tee --append build-all.LOG

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
	&& cp "$INSTALL_APP_DIR"/scripts/pre-setup.sh    "$INSTALL_APP_DIR"/ \
	&& cp "$INSTALL_APP_DIR"/scripts/load-default.sh "$INSTALL_APP_DIR"/ 
#RUN "$INSTALL_APP_DIR"/bin/sysrepocfg -C startup -d running -m rbbn-nos-host


# Prepare GUI
#RUN unzip /root/netopeer2-all-build/liberouter-gui-master.zip -d / ; mv /liberouter-gui-master /liberouter-gui
#RUN unzip /root/netopeer2-all-build/Netopeer2GUI-2.zip -d /liberouter-gui/modules ; mv /liberouter-gui/modules/Netopeer2GUI-2 /liberouter-gui/modules/netopeer2gui
WORKDIR /
RUN git clone https://github.com/CESNET/liberouter-gui
RUN cd /liberouter-gui/modules && git clone -b v2 https://github.com/CESNET/netopeer2gui 
# && rm -rf /liberouter-gui/modules/example
RUN cp /liberouter-gui/modules/netopeer2gui/app.config.json /liberouter-gui/modules/app.config.json && rm /liberouter-gui/modules/netopeer2gui/app.config.json
RUN cd /liberouter-gui && python3 bootstrap.py && \
    pip3 install -r backend/requirements.txt && \
    cd frontend && npm install -g npm@7.5.2 && \
    npm i -g @angular/cli && npm install --legacy-peer-deps

# Temporary workaround until import is fixed for tools
RUN rm /liberouter-gui/modules/netopeer2gui/frontend/projects/shared-styles/_colors.scss && \
  cp /liberouter-gui/frontend/src/styles/_colors.scss /liberouter-gui/modules/netopeer2gui/frontend/projects/shared-styles/_colors.scss
RUN echo "\$colorSuccess:     #44bd32;" >> /liberouter-gui/modules/netopeer2gui/frontend/projects/shared-styles/_colors.scss && \
    echo "\$colorError:       #ee1d23;" >> /liberouter-gui/modules/netopeer2gui/frontend/projects/shared-styles/_colors.scss

# Build GUI
RUN cd /liberouter-gui/modules/netopeer2gui/frontend && npm i && npm run build:tools && cd
RUN cd /liberouter-gui/frontend && npm run build && cp -R dist/* /var/www/html 

# Setup ngix server with uwsgi
RUN mkdir -p /var/www/liberouter-gui && cp -r /liberouter-gui/backend /var/www/liberouter-gui
RUN rm /var/www/liberouter-gui/backend/liberouterapi/modules/netconf && cp -r /liberouter-gui/modules/netopeer2gui/backend/. /var/www/liberouter-gui/backend/liberouterapi/modules/netopeer2gui
RUN cp /liberouter-gui/modules/netopeer2gui/docker/wsgi.py /var/www/liberouter-gui/backend/wsgi.py
RUN pip3 install wheel && pip3 install uwsgi; mkdir /uwsgi; chown -R www-data:www-data /uwsgi

#COPY localhost /etc/nginx/sites-available/
#RUN ln /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled
#COPY config.ini /var/www/liberouter-gui/backend/config.ini
#COPY .htaccess /var/www/html/.htaccess
RUN cp /liberouter-gui/modules/netopeer2gui/docker/demo/localhost /etc/nginx/sites-available/ ;\
	ln /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled ;\
	cp /liberouter-gui/modules/netopeer2gui/docker/demo/config.ini /var/www/liberouter-gui/backend/config.ini ;\
	cp /liberouter-gui/modules/netopeer2gui/docker/demo/.htaccess /var/www/html/.htaccess

RUN chown -R www-data:www-data /var/www/liberouter-gui
RUN chown -R www-data:www-data /liberouter-gui/modules/netopeer2gui/backend
# App needs to write configuration files
RUN chmod -R +w /var/www/liberouter-gui/backend/liberouterapi/modules/netopeer2gui/ ; mkdir -p /var/www/liberouter-gui/backend/liberouterapi/modules/netopeer2gui/userfiles
RUN rm /etc/nginx/sites-enabled/default
RUN pip3 install Flask-SocketIO==4.3.2

# Change root password for netconf connection
# DO NOT USE IN PRODUCTION ENVIRONMENT!
#RUN echo 'root:docker' | chpasswd

# Expose HTTP
EXPOSE 80/tcp
EXPOSE 5555/tcp
# EXPOSE 830

#COPY services.sh /root
RUN cp /liberouter-gui/modules/netopeer2gui/docker/demo/services.sh /root
CMD ["/bin/bash", "/root/services.sh"]



#CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]

### for develop
#RUN "$INSTALL_APP_DIR"/scripts/Netopeer2GUI_install.sh 2>&1 | tee --append Netopeer2GUI_install.sh.LOG
