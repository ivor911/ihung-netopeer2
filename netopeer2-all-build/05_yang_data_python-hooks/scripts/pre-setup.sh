#!/bin/bash
NETCONF_YANG_DIR=$1
${NETCONF_YANG_DIR}/scripts/setup_sysrepo_modules.sh ${NETCONF_YANG_DIR}/bin/sysrepoctl ${NETCONF_YANG_DIR}/yang_common
${NETCONF_YANG_DIR}/scripts/merge_hostkey.sh         ${NETCONF_YANG_DIR}/bin/sysrepocfg openssl
${NETCONF_YANG_DIR}/scripts/merge_config.sh          ${NETCONF_YANG_DIR}/bin/sysrepocfg genkey
