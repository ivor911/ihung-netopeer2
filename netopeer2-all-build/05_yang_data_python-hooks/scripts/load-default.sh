#!/bin/bash
NETCONF_YANG_DIR=$1

# clean all sysrepo share memory contents
rm -fr /dev/shm/sr_*
rm -f  /netconf-yang/sr_main_lock

# load default xml into sysrepo startup datastore
${NETCONF_YANG_DIR}/bin/sysrepocfg --import=${NETCONF_YANG_DIR}/scripts/turing-machine-default.xml -d startup -m turing-machine 
${NETCONF_YANG_DIR}/bin/sysrepocfg --import=${NETCONF_YANG_DIR}/scripts/oven-default.xml           -d startup -m oven

# load default xml into sysrepo running datastore
${NETCONF_YANG_DIR}/bin/sysrepocfg --import=${NETCONF_YANG_DIR}/scripts/turing-machine-default.xml -d running -m turing-machine 
${NETCONF_YANG_DIR}/bin/sysrepocfg --import=${NETCONF_YANG_DIR}/scripts/oven-default.xml           -d running -m oven


