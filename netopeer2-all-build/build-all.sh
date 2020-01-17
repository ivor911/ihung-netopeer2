#!/bin/bash
INSTALL_ROOT="/hicn-root"

PATH_PWD="`pwd`"
PATH_LIBYANG="${PATH_PWD}/01_libyang"
PATH_SYSREPO="${PATH_PWD}/02_sysrepo"
PATH_LIBNETCONF2="${PATH_PWD}/03_libnetconf2"
PATH_NETOPEER2="${PATH_PWD}/04_Netopeer2"

TARBALL_LIBYANG="libyang-1.0.109.tar.gz"
TARBALL_LIBNETCONF2="libnetconf2-1.1.3.tar.gz"
TARBALL_SYSREPO="sysrepo-1.3.21.tar.gz"
TARBALL_NETOPEER2="Netopeer2-1.1.1.tar.gz"

F_PATCH_SYSREPO="${PATH_SYSREPO}/sysrepo-1.3.21.patch"

DIR_LIBYANG="libyang-1.0.109"
DIR_LIBNETCONF2="libnetconf2-1.1.3"
DIR_SYSREPO="sysrepo-1.3.21"
DIR_NETOPEER2="Netopeer2-1.1.1"

I_01_LIBYANG_BUILD="ENABLE"
I_02_SYSREPO_BUILD="ENABLE"
I_03_LIBNETCONF2_BUILD="ENABLE"
I_04_NETOPEER2_BUILD="ENABLE"


function ldconfig_update()
{
	echo "${INSTALL_ROOT}/lib" > /etc/ld.so.conf.d/hicn-root.conf
	ldconfig
}



#00_hicn-root

mkdir -p ${INSTALL_ROOT}

#01_libyang
if [ "${I_01_LIBYANG_BUILD}" = "ENABLE" ]; then

	printf "${PATH_LIBYANG} \n"
	rm -fr "${PATH_LIBYANG}/${DIR_LIBYANG}"

	cd ${PATH_LIBYANG}
	tar -zxvf ./${TARBALL_LIBYANG}
	mkdir -p ${DIR_LIBYANG}/build
	pushd ${DIR_LIBYANG}/build
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT} ..
	make
	make install
	popd

	ldconfig_update
fi

#02_sysrepo
if [ "${I_02_SYSREPO_BUILD}" = "ENABLE" ]; then

	printf "${PATH_SYSREPO} \n"
	rm -fr "${PATH_SYSREPO}/${DIR_SYSREPO}"

	cd ${PATH_SYSREPO}
	tar -zxvf ./${TARBALL_SYSREPO}

	#############################################################
	# patching
	# sed -i 's/\/etc\/sysrepo/\/hicn-root/' CMakeLists.txt
	#sed -i "s/\/etc\/sysrepo/\${INSTALL_ROOT}/" CMakeLists.txt
	pushd ${DIR_SYSREPO}
	patch -p2 < ${F_PATCH_SYSREPO}
	popd
	
	mkdir -p ${DIR_SYSREPO}/build
	pushd ${DIR_SYSREPO}/build
	cmake -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT} \
	-DCMAKE_INCLUDE_PATH=${INSTALL_ROOT}/include \
	-DCMAKE_LIBRARY_PATH=${INSTALL_ROOT}/lib \
	-DLIBYANG_INCLUDE_DIR=${INSTALL_ROOT}/include \
	-DLIBYANG_LIBRARY=${INSTALL_ROOT}/lib/libyang.so \
	-DREPOSITORY_LOC=${INSTALL_ROOT} -DREPO_PATH=${INSTALL_ROOT} ..
	make
	make install
	popd

	ldconfig_update
fi

#03_libnetconf2
if [ "${I_03_LIBNETCONF2_BUILD}" = "ENABLE" ]; then

	printf "${PATH_LIBNETCONF2} \n"
	rm -fr "${PATH_LIBNETCONF2}/${DIR_LIBNETCONF2}"

	cd ${PATH_LIBNETCONF2}
	tar -zxvf ./${TARBALL_LIBNETCONF2}
	mkdir -p ${DIR_LIBNETCONF2}/build
	pushd ${DIR_LIBNETCONF2}/build
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT} ..
	make
	make install
	popd

	ldconfig_update
fi

#04_Netopeer2
if [ "${I_04_NETOPEER2_BUILD}" = "ENABLE" ]; then

	printf "${PATH_NETOPEER2} \n"
	rm -fr "${PATH_NETOPEER2}/${DIR_NETOPEER2}"

	cd ${PATH_NETOPEER2}
	tar -zxvf ./${TARBALL_NETOPEER2}


	#server
	mkdir -p ${DIR_NETOPEER2}/server/build
	pushd ${DIR_NETOPEER2}/server/build
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT} ..
	make
	make install
	popd
	ldconfig_update

	#cli
	mkdir -p ${DIR_NETOPEER2}/cli/build
	pushd ${DIR_NETOPEER2}/cli/build
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT} ..
	make
	make install
	popd
	ldconfig_update
fi

