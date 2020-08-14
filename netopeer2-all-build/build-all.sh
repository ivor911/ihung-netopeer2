#!/bin/bash
APP_NAME="netconf-yang"
INSTALL_APP_DIR="/${APP_NAME}"

PATH_PWD="`pwd`"
PATH_LIBYANG="${PATH_PWD}/01_libyang"
PATH_SYSREPO="${PATH_PWD}/02_sysrepo"
PATH_LIBNETCONF2="${PATH_PWD}/03_libnetconf2"
PATH_NETOPEER2="${PATH_PWD}/04_netopeer2"


#############################################################
#: <<'ReleaseAt20200721'
TARBALL_LIBYANG=libyang-1.0.184.tar.gz
TARBALL_SYSREPO=sysrepo-1.4.70.tar.gz
TARBALL_LIBNETCONF2=libnetconf2-1.1.26.tar.gz
TARBALL_NETOPEER2=netopeer2-1.1.39.tar.gz
DIR_LIBYANG=libyang-1.0.184
DIR_SYSREPO=sysrepo-1.4.70
DIR_LIBNETCONF2=libnetconf2-1.1.26
DIR_NETOPEER2=netopeer2-1.1.39
F_PATCH_LIBYANG=${PATH_LIBYANG}/${DIR_LIBYANG}.patch
F_PATCH_SYSREPO=${PATH_SYSREPO}/${DIR_SYSREPO}.patch
F_PATCH_LIBNETCONF2=${PATH_LIBNETCONF2}/${DIR_LIBNETCONF2}.patch
F_PATCH_NETOPEER2=${PATH_NETOPEER2}/${DIR_NETOPEER2}.patch
#ReleaseAt20200721
#############################################################

: <<'ReleaseAt20200507withNetopeer2Update'
TARBALL_LIBYANG=libyang-1.0.167.tar.gz
TARBALL_SYSREPO=sysrepo-1.4.58.tar.gz
TARBALL_LIBNETCONF2=libnetconf2-1.1.24.tar.gz
TARBALL_NETOPEER2=netopeer2-1.1.34.tar.gz
DIR_LIBYANG=libyang-1.0.167
DIR_SYSREPO=sysrepo-1.4.58
DIR_LIBNETCONF2=libnetconf2-1.1.24
DIR_NETOPEER2=netopeer2-1.1.34
F_PATCH_LIBYANG=${PATH_LIBYANG}/${DIR_LIBYANG}.patch
F_PATCH_SYSREPO=${PATH_SYSREPO}/${DIR_SYSREPO}.patch
F_PATCH_LIBNETCONF2=${PATH_LIBNETCONF2}/${DIR_LIBNETCONF2}.patch
F_PATCH_NETOPEER2=${PATH_NETOPEER2}/${DIR_NETOPEER2}.patch
ReleaseAt20200507withNetopeer2Update

: <<'ReleaseAt20191213'
TARBALL_LIBYANG="libyang-1.0.109.tar.gz"
TARBALL_LIBNETCONF2="libnetconf2-1.1.3.tar.gz"
TARBALL_SYSREPO="sysrepo-1.3.21.tar.gz"
TARBALL_NETOPEER2="Netopeer2-1.1.1.tar.gz"

F_PATCH_SYSREPO="${PATH_SYSREPO}/sysrepo-1.3.21.patch"
F_PATCH_LIBNETCONF2="${PATH_LIBNETCONF2}/libnetconf2-1.1.3.patch"

DIR_LIBYANG="libyang-1.0.109"
DIR_LIBNETCONF2="libnetconf2-1.1.3"
DIR_SYSREPO="sysrepo-1.3.21"
DIR_NETOPEER2="Netopeer2-1.1.1"
ReleaseAt20191213

: <<'ReleaseAt20200203'
TARBALL_LIBYANG="libyang-1.0.130.tar.gz"
TARBALL_SYSREPO="sysrepo-1.4.2.tar.gz"
TARBALL_LIBNETCONF2="libnetconf2-1.1.7.tar.gz"
TARBALL_NETOPEER2="Netopeer2-1.1.7.tar.gz"

F_PATCH_SYSREPO="${PATH_SYSREPO}/sysrepo-1.4.2.patch"
F_PATCH_LIBNETCONF2="${PATH_LIBNETCONF2}/libnetconf2-1.1.7.patch"

DIR_LIBYANG="libyang-1.0.130"
DIR_SYSREPO="sysrepo-1.4.2"
DIR_LIBNETCONF2="libnetconf2-1.1.7"
DIR_NETOPEER2="Netopeer2-1.1.7"
ReleaseAt20200203



: <<'DevelVersion'
TARBALL_LIBYANG="libyang-1.0.157-devel.tar.gz"
TARBALL_SYSREPO="sysrepo-1.4.37-devel.tar.gz"
TARBALL_LIBNETCONF2="libnetconf2-1.1.18-devel.tar.gz"
TARBALL_NETOPEER2="Netopeer2-1.1.20-devel-server.tar.gz"

F_PATCH_SYSREPO="${PATH_SYSREPO}/sysrepo-1.4.37-devel.patch"
F_PATCH_LIBNETCONF2="${PATH_LIBNETCONF2}/libnetconf2-1.1.18-devel.patch"

DIR_LIBYANG="libyang-1.0.157-devel"
DIR_SYSREPO="sysrepo-1.4.37-devel"
DIR_LIBNETCONF2="libnetconf2-1.1.18-devel"
DIR_NETOPEER2="Netopeer2-1.1.20-devel-server"
DevelVersion
#############################################################

I_01_LIBYANG_BUILD="ENABLE"
I_02_SYSREPO_BUILD="ENABLE"
I_02_SYSREPO_EXAMPLE_COPY="ENABLE"
I_03_LIBNETCONF2_BUILD="ENABLE"
I_04_NETOPEER2_BUILD="ENABLE"
I_05_CPU_CORES="$(grep processor /proc/cpuinfo | wc -l)"
if [ -n "${I_05_CPU_CORES}" ]; then
    I_MAKE_J_CMD="make -j${I_05_CPU_CORES}"
else
    I_MAKE_J_CMD="make"
fi


GEN_I_EXP_YANG_FILE="./examples/building@2018-01-22.yang"
GEN_I_EXP_XML_FILE="./examples/building-import.xml"
GEN_I_EXP_README_FILE="./examples/README"

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

function generate_myexamples()
{
cat << EOF > ${GEN_I_EXP_README_FILE}
Ref:
	* Install a YANG model
		https://asciinema.org/a/160037
	* How to run a Sysrepo application
	https://asciinema.org/a/160090

	# install module
	  $ sysrepoctl -i /netconf-yang/sysrepo_examples/building@2018-01-20.yang -p 666
	  $ sysrepoctl -l | grep building

	# run a sysrepo example application
	  $ /netconf-yang/sysrepo_examples/application_changes_example building

	# remove module
	  $ sysrepoctl -u building

    #################################################################################
	$ apt-get update; apt-get -y install net-tools vim less tree
	$ sysrepocfg --edit=vim -d running --module=building
	$ sysrepocfg --edit=vim -d startup --module=building
	$ sysrepocfg --import=/netconf-yang/sysrepo_examples/building-import.xml

EOF
cat << EOF > ${GEN_I_EXP_XML_FILE}
<rooms xmlns="urn:building:test">
  <room>
    <room-number>10</room-number>
    <size>100</size>
  </room>
</rooms>
EOF
cat << EOF > ${GEN_I_EXP_YANG_FILE}
module building {
  yang-version 1;
  namespace "urn:building:test";

  prefix bld;

  organization "building";
  contact "building address";
  description "yang model for buildings";
  revision "2018-01-22" {
    description "initial revision";
  }
  // now we can add data nodes

  container rooms {
    list room {
	  key room-number;
      leaf room-number {
        type uint16;
      }
      leaf size {
        type uint32;
      }
    }
  }
}
EOF
}


#00_APP

mkdir -p ${INSTALL_APP_DIR}
pkg_config_path

#01_libyang
if [ "${I_01_LIBYANG_BUILD}" = "ENABLE" ]; then

	printf "\n\n ihung-BUILDING ${PATH_LIBYANG} \n"
	rm -fr "${PATH_LIBYANG}/${DIR_LIBYANG}"

	cd ${PATH_LIBYANG}
	tar -zxvf ./${TARBALL_LIBYANG}

	#############################################################
	# patching
	pushd ${DIR_LIBYANG}
	patch -p2 < ${F_PATCH_LIBYANG}
	popd
    #############################################################

	mkdir -p ${DIR_LIBYANG}/build
	pushd ${DIR_LIBYANG}/build

	cmake -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_PREFIX=${INSTALL_APP_DIR} \
	-DGEN_LANGUAGE_BINDINGS=ON \
	-DGEN_CPP_BINDINGS=ON \
	-DGEN_PYTHON_BINDINGS=ON ..

    #eval ${I_MAKE_J_CMD}
    make
	make install
	popd

	ldconfig_update
fi

#02_sysrepo
if [ "${I_02_SYSREPO_BUILD}" = "ENABLE" ]; then

	printf "\n\n ihung-BUILDING ${PATH_SYSREPO} \n"
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
    #############################################################
	
	mkdir -p ${DIR_SYSREPO}/build
	pushd ${DIR_SYSREPO}/build

	cmake -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_PREFIX=${INSTALL_APP_DIR} \
	-DCMAKE_INCLUDE_PATH=${INSTALL_APP_DIR}/include \
	-DCMAKE_LIBRARY_PATH=${INSTALL_APP_DIR}/lib \
	-DLIBYANG_INCLUDE_DIR=${INSTALL_APP_DIR}/include \
	-DLIBYANG_LIBRARY=${INSTALL_APP_DIR}/lib/libyang.so \
	-DGEN_LANGUAGE_BINDINGS=ON \
	-DGEN_CPP_BINDINGS=ON \
	-DGEN_PYTHON_BINDINGS=ON \
    -DPLUGINS_PATH=$(INSTALL_APP_DIR)/sysrepo-plugind/plugins \
	-DREPOSITORY_LOC=${INSTALL_APP_DIR} -DREPO_PATH=${INSTALL_APP_DIR} ..

    #eval ${I_MAKE_J_CMD}
    make
	make install
	if [ "${I_02_SYSREPO_EXAMPLE_COPY}" = "ENABLE" ]; then
		mkdir -p ${INSTALL_APP_DIR}/sysrepo_examples
		cp ./examples/*_example			${INSTALL_APP_DIR}/sysrepo_examples
		cp ./examples/liboven.so		${INSTALL_APP_DIR}/lib
		cp ../examples/examples.yang	${INSTALL_APP_DIR}/sysrepo_examples
		generate_myexamples
		cp ${GEN_I_EXP_YANG_FILE}				${INSTALL_APP_DIR}/sysrepo_examples
		cp ${GEN_I_EXP_XML_FILE}				${INSTALL_APP_DIR}/sysrepo_examples
		cp ${GEN_I_EXP_README_FILE}				${INSTALL_APP_DIR}/sysrepo_examples
	fi
	popd

	ldconfig_update
fi

#03_libnetconf2
if [ "${I_03_LIBNETCONF2_BUILD}" = "ENABLE" ]; then

	printf "\n\n ihung-BUILDING ${PATH_LIBNETCONF2} \n"
	rm -fr "${PATH_LIBNETCONF2}/${DIR_LIBNETCONF2}"

	cd ${PATH_LIBNETCONF2}
	tar -zxvf ./${TARBALL_LIBNETCONF2}

	#############################################################
	# patching
	pushd ${DIR_LIBNETCONF2}
	patch -p2 < ${F_PATCH_LIBNETCONF2}
	popd
    #############################################################

	mkdir -p ${DIR_LIBNETCONF2}/build
	pushd ${DIR_LIBNETCONF2}/build

	cmake -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_PREFIX=${INSTALL_APP_DIR}  \
	-DCMAKE_INCLUDE_PATH=${INSTALL_APP_DIR}/include \
	-DCMAKE_LIBRARY_PATH=${INSTALL_APP_DIR}/lib \
	-DLIBYANG_INCLUDE_DIR=${INSTALL_APP_DIR}/include \
	-DLIBYANG_LIBRARY=${INSTALL_APP_DIR}/lib/libyang.so \
    -DENABLE_SSH=ON \
    -DENABLE_TLS=ON \
	-DENABLE_PYTHON=ON ..

    #eval ${I_MAKE_J_CMD}
    make
	make install
	popd

	ldconfig_update
fi

#04_Netopeer2
if [ "${I_04_NETOPEER2_BUILD}" = "ENABLE" ]; then

	printf "\n\n ihung-BUILDING ${PATH_NETOPEER2} \n"
	rm -fr "${PATH_NETOPEER2}/${DIR_NETOPEER2}"

	cd ${PATH_NETOPEER2}
	tar -zxvf ./${TARBALL_NETOPEER2}


	#server and cli 
	mkdir -p ${DIR_NETOPEER2}/build
	pushd ${DIR_NETOPEER2}/build

	cmake -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
    -DINSTALL_MODULES=OFF   \
    -DGENERATE_HOSTKEY=OFF  \
    -DMERGE_LISTEN_CONFIG=OFF \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_APP_DIR} ..

    #eval ${I_MAKE_J_CMD}
    make
	make install
	popd
	ldconfig_update
fi

# Prepare and listing all *.py examples
mkdir -p /python_examples_NEW
find /root/netopeer2-all-build -name "*.py" >  /python_examples_NEW/00_FILE-LIST.txt
printf "\n\n Created date:   "              >> /python_examples_NEW/00_FILE-LIST.txt
date                                        >> /python_examples_NEW/00_FILE-LIST.txt
find /root/netopeer2-all-build -name "*.py"  | xargs -I {} cp -u {} /python_examples_NEW
chmod +x /python_examples_NEW/*.py

# copy SWIG bindings definitation (SWIG interface file, the .i file)
mkdir -p /python_bindings
pushd /root/netopeer2-all-build
find  ./ -name "*.i" >  /python_bindings/00_FILE-LIST.txt
printf "\n\n Created date:   "              >> /python_bindings/00_FILE-LIST.txt
date                                        >> /python_bindings/00_FILE-LIST.txt
find ./ -name "*.i" | xargs -I {}  dirname {}  > /python_bindings/dirname
pushd /python_bindings/
awk '{print $1}' /python_bindings/dirname | xargs -I {} mkdir -p {}
rm -f /python_bindings/dirname
popd
find ./ -name "*.i" | xargs -I {} cp {}  "/python_bindings/{}"
popd

cp -r /root/netopeer2-all-build/05_yang_data_python-hooks/* ${INSTALL_APP_DIR}/
