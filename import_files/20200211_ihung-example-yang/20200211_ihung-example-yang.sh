#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SYSREPOCTL=`command -v sysrepoctl`
YANG_DIR="/netconf-yang/yang"

I_YANG_MODULES=(  ietf-inet-types@2013-07-15.yang
				ietf-yang-types@2013-07-15.yang
				ietf-interfaces@2014-05-08.yang
				ietf-ip@2014-06-16.yang
				iana-if-type@2017-01-19.yang )

I_YANG_MODULES_NAME=(  ietf-inet-types
				  ietf-yang-types
				  ietf-interfaces
				  ietf-ip
				  iana-if-type )

for i in "${I_YANG_MODULES[@]}"
do

	echo "cp ${DIR}/${i} ${YANG_DIR}/"
	cp ${DIR}/${i} ${YANG_DIR}/

	echo "${SYSREPOCTL} --install ${YANG_DIR}/${i}"
	${SYSREPOCTL} --install ${YANG_DIR}/${i}
	I_YANG_MODULE_NAME=`echo ${i}|cut -d @ -f 1`

	echo "${SYSREPOCTL} --change ${I_YANG_MODULE_NAME} --permissions 666"
	${SYSREPOCTL} --change ${I_YANG_MODULE_NAME} --permissions 666
	
	echo ""

	sleep 1
done

# sysrepocfg --import=${DIR}/import_ietf-interfaces.xml
# sysrepocfg --import=/20200211_ihung-example-yang/import_ietf-interfaces.xml


