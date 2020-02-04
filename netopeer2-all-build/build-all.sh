#!/bin/bash
APP_NAME="netconf-yang"
INSTALL_APP_DIR="/${APP_NAME}"

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
I_02_SYSREPO_EXAMPLE_COPY="ENABLE"
I_03_LIBNETCONF2_BUILD="ENABLE"
I_04_NETOPEER2_BUILD="ENABLE"

function pkg_config_path()
{
	if [ -z "${PKG_CONFIG_PATH}" ]; then
		export PKG_CONFIG_PATH="/netconf-yang/lib/pkgconfig"
	else
		export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/netconf-yang/lib/pkgconfig"
	fi
}

function ldconfig_update()
{
	echo "${INSTALL_APP_DIR}/lib" > /etc/ld.so.conf.d/ld-${APP_NAME}.conf
	ldconfig
}



#00_APP

mkdir -p ${INSTALL_APP_DIR}
pkg_config_path

#01_libyang
if [ "${I_01_LIBYANG_BUILD}" = "ENABLE" ]; then

	printf "${PATH_LIBYANG} \n"
	rm -fr "${PATH_LIBYANG}/${DIR_LIBYANG}"

	cd ${PATH_LIBYANG}
	tar -zxvf ./${TARBALL_LIBYANG}
	mkdir -p ${DIR_LIBYANG}/build
	pushd ${DIR_LIBYANG}/build
	cmake -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=${INSTALL_APP_DIR} \
	-DGEN_LANGUAGE_BINDINGS=ON \
	-DGEN_CPP_BINDINGS=ON \
	-DGEN_PYTHON_BINDINGS=ON ..
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
	# sed -i 's/\/etc\/sysrepo/\/netconf-yang/' CMakeLists.txt
	#sed -i "s/\/etc\/sysrepo/\${INSTALL_APP_DIR}/" CMakeLists.txt
	pushd ${DIR_SYSREPO}
	patch -p2 < ${F_PATCH_SYSREPO}
	popd
	
	mkdir -p ${DIR_SYSREPO}/build
	pushd ${DIR_SYSREPO}/build
	cmake -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=${INSTALL_APP_DIR} \
	-DCMAKE_INCLUDE_PATH=${INSTALL_APP_DIR}/include \
	-DCMAKE_LIBRARY_PATH=${INSTALL_APP_DIR}/lib \
	-DLIBYANG_INCLUDE_DIR=${INSTALL_APP_DIR}/include \
	-DLIBYANG_LIBRARY=${INSTALL_APP_DIR}/lib/libyang.so \
	-DGEN_LANGUAGE_BINDINGS=ON \
	-DGEN_CPP_BINDINGS=ON \
	-DGEN_PYTHON_BINDINGS=ON \
	-DREPOSITORY_LOC=${INSTALL_APP_DIR} -DREPO_PATH=${INSTALL_APP_DIR} ..
	make
	make install
	if [ "${I_02_SYSREPO_EXAMPLE_COPY}" = "ENABLE" ]; then
		mkdir -p ${INSTALL_APP_DIR}/sysrepo_examples
		cp ./examples/*_example			${INSTALL_APP_DIR}/sysrepo_examples
		cp ./examples/liboven.so		${INSTALL_APP_DIR}/lib
		cp ../examples/examples.yang	${INSTALL_APP_DIR}/sysrepo_examples
	fi
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
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_APP_DIR} ..
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
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_APP_DIR} ..
	make
	make install
	popd
	#copy server scripts
	cp ./${DIR_NETOPEER2}/server/*.sh ${INSTALL_APP_DIR}/bin
	chmod +x ${INSTALL_APP_DIR}/bin/*.sh
	ldconfig_update

	#cli
	mkdir -p ${DIR_NETOPEER2}/cli/build
	pushd ${DIR_NETOPEER2}/cli/build
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_APP_DIR} ..
	make
	make install
	popd
	ldconfig_update
fi

