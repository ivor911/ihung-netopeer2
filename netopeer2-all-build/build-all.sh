#!/bin/bash

PATH_PWD="`pwd`"
PATH_LIBYANG="${PATH_PWD}/01_libyang"
PATH_LIBNETCONF2="${PATH_PWD}/02_libnetconf2"
PATH_SYSREPO="${PATH_PWD}/03_sysrepo"
PATH_NETOPEER2="${PATH_PWD}/04_Netopeer2"

TARBALL_LIBYANG="libyang-1.0.109.tar.gz"
TARBALL_LIBNETCONF2="libnetconf2-1.1.3.tar.gz"
TARBALL_SYSREPO="sysrepo-1.3.21.tar.gz"
TARBALL_NETOPEER2="Netopeer2-1.1.1.tar.gz"

DIR_LIBYANG="libyang-1.0.109"
DIR_LIBNETCONF2="libnetconf2-1.1.3"
DIR_SYSREPO="sysrepo-1.3.21"
DIR_NETOPEER2="Netopeer2-1.1.1"

I_01_LIBYANG_BUILD="ENABLE"
I_02_LIBNETCONF2_BUILD="ENABLE"
I_03_SYSREPO_BUILD="ENABLE"
I_04_NETOPEER2_BUILD="ENABLE"

#01_libyang
if [ "${I_01_LIBYANG_BUILD}" = "ENABLE" ]; then

	printf "${PATH_LIBYANG} \n"
	rm -fr "${PATH_LIBYANG}/${DIR_LIBYANG}"

	cd ${PATH_LIBYANG}
	tar -zxvf ./${TARBALL_LIBYANG}
	cd ${DIR_LIBYANG}
	mkdir build
	cd build
	cmake ..
	make
	make install
	ldconfig
fi


#02_libnetconf2
if [ "${I_02_LIBNETCONF2_BUILD}" = "ENABLE" ]; then

	printf "${PATH_LIBNETCONF2} \n"
	rm -fr "${PATH_LIBNETCONF2}/${DIR_LIBNETCONF2}"

	cd ${PATH_LIBNETCONF2}
	tar -zxvf ./${TARBALL_LIBNETCONF2}
	cd ${DIR_LIBNETCONF2}
	mkdir build
	cd build
	cmake ..
	make
	make install
	ldconfig
fi

#03_sysrepo
if [ "${I_03_SYSREPO_BUILD}" = "ENABLE" ]; then

	printf "${PATH_SYSREPO} \n"
	rm -fr "${PATH_SYSREPO}/${DIR_SYSREPO}"

	cd ${PATH_SYSREPO}
	tar -zxvf ./${TARBALL_SYSREPO}
	cd ${DIR_SYSREPO}
	mkdir build
	cd build
	cmake ..
	make
	make install
	ldconfig
fi

#04_Netopeer2
if [ "${I_04_NETOPEER2_BUILD}" = "ENABLE" ]; then

	printf "${PATH_NETOPEER2} \n"
	rm -fr "${PATH_NETOPEER2}/${DIR_NETOPEER2}"

	cd ${PATH_NETOPEER2}
	tar -zxvf ./${TARBALL_NETOPEER2}

	#server
	cd ${DIR_NETOPEER2}/server
	mkdir build
	cd build
	cmake ..
	make
	make install
	ldconfig

	#cli
	cd ../../cli
	mkdir build
	cd build
	cmake ..
	make
	make install
	ldconfig

fi
