#!/bin/bash
APP_NAME=netconf-yang
INSTALL_APP_DIR="/${APP_NAME}"

"$INSTALL_APP_DIR"/bin/setup.sh         "$INSTALL_APP_DIR"/bin/sysrepoctl /netconf-yang/yang root
"$INSTALL_APP_DIR"/bin/merge_hostkey.sh "$INSTALL_APP_DIR"/bin/sysrepocfg openssl
"$INSTALL_APP_DIR"/bin/merge_config.sh  "$INSTALL_APP_DIR"/bin/sysrepocfg genkey

