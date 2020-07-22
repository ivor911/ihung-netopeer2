#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage $0 <sysrepoctl-path> <netopeer2-modules-directory> [<module-owner>]"
    exit
fi

#set -e

SYSREPOCTL=$1
MODDIR=$2
OWNER=root
GROUP=root

rm -fr /dev/shm/sr_*
rm -f  /netconf-yang/sr_main_lock
rm -fr /netconf-yang/data
rm -fr /netconf-yang/yang

#01_libyang/libyang-1.0.167/models/
MODULES_FROM_01_LIBYANG=(
"ietf-datastores@2018-02-14.yang"
"ietf-inet-types@2013-07-15.yang"
"ietf-yang-library@2019-01-04.yang"
"ietf-yang-metadata@2016-08-05.yang"
"ietf-yang-types@2013-07-15.yang"
"yang@2017-02-20.yang"
)
#02_sysrepo/sysrepo-1.4.58/modules/
MODULES_FROM_02_SYSREPO=(
"ietf-datastores.yang"
"ietf-netconf-notifications.yang"
"ietf-netconf-with-defaults.yang"
"ietf-netconf.yang"
"ietf-origin.yang"
"ietf-yang-library@2016-06-21.yang"
"ietf-yang-library@2019-01-04.yang"
"sysrepo-monitoring.yang"
"sysrepo.yang"
)
#03_libnetconf2/libnetconf2-1.1.24/modules
MODULES_FROM_03_LIBNETCONF2=(
"ietf-netconf-acm@2018-02-14.yang"
"ietf-netconf-monitoring@2010-10-04.yang"
"ietf-netconf@2013-09-29.yang"
)

#04_netopeer2/netopeer2-1.1.27/modules
MODULES_FROM_04_NETOPEER2=(
"iana-crypt-hash@2014-08-06.yang"
"ietf-crypto-types@2019-07-02.yang"
"ietf-datastores@2017-08-17.yang"
"ietf-keystore@2019-07-02.yang"
"ietf-netconf-acm@2018-02-14.yang"
"ietf-netconf-monitoring@2010-10-04.yang"
"ietf-netconf-nmda@2019-01-07.yang"
"ietf-netconf-server@2019-07-02.yang"
"ietf-netconf@2013-09-29.yang"
"ietf-ssh-common@2019-07-02.yang"
"ietf-ssh-server@2019-07-02.yang"
"ietf-tcp-client@2019-07-02.yang"
"ietf-tcp-common@2019-07-02.yang"
"ietf-tcp-server@2019-07-02.yang"
"ietf-tls-common@2019-07-02.yang"
"ietf-tls-server@2019-07-02.yang"
"ietf-truststore@2019-07-02.yang"
"ietf-x509-cert-to-name@2014-12-10.yang"
"nc-notifications@2008-07-14.yang"
"notifications@2008-07-14.yang"
)

# array of modules to install
MODULES=(
"ietf-netconf-acm@2018-02-14.yang"
"ietf-netconf@2013-09-29.yang -e writable-running -e candidate -e rollback-on-error -e validate -e startup -e url -e xpath"
"ietf-netconf-monitoring@2010-10-04.yang"
"ietf-netconf-nmda@2019-01-07.yang -e origin -e with-defaults"
"nc-notifications@2008-07-14.yang"
"notifications@2008-07-14.yang"
"ietf-x509-cert-to-name@2014-12-10.yang"
"ietf-crypto-types@2019-07-02.yang"
"ietf-keystore@2019-07-02.yang -e keystore-supported"
"ietf-truststore@2019-07-02.yang -e truststore-supported -e x509-certificates"
"ietf-tcp-common@2019-07-02.yang -e keepalives-supported"
"ietf-ssh-server@2019-07-02.yang -e local-client-auth-supported"
"ietf-tls-server@2019-07-02.yang -e local-client-auth-supported"
"ietf-netconf-server@2019-07-02.yang -e ssh-listen -e tls-listen -e ssh-call-home -e tls-call-home"
"ietf-tcp-client@2019-07-02.yang"
"ietf-tcp-server@2019-07-02.yang"
"ietf-ssh-common@2019-07-02.yang"
"ietf-tls-common@2019-07-02.yang"
"ietf-inet-types@2013-07-15.yang"
"ietf-yang-types@2013-07-15.yang"
"iana-crypt-hash@2014-08-06.yang"
"ietf-system@2014-08-06.yang"
"ietf-yang-metadata@2016-08-05.yang"
"turing-machine.yang"
"oven.yang"
)

# functions
INSTALL_MODULE() {
    $SYSREPOCTL -a -i $MODDIR/$1 -s $MODDIR -o $OWNER -g $GROUP -v2
    local rc=$?
    if [ $rc -ne 0 ]; then
        exit $rc
    fi
}

UPDATE_MODULE() {
    $SYSREPOCTL -a -U $MODDIR/$1 -s $MODDIR -o $OWNER -g $GROUP -v2
    local rc=$?
    if [ $rc -ne 0 ]; then
        exit $rc
    fi
}

ENABLE_FEATURE() {
    $SYSREPOCTL -a -c $1 -e $2 -v2
    local rc=$?
    if [ $rc -ne 0 ]; then
        exit $rc
    fi
}

# get current modules
SCTL_MODULES=`$SYSREPOCTL -l`

for i in "${MODULES[@]}"; do
    name=`echo "$i" | sed 's/\([^@]*\).*/\1/'`

    SCTL_MODULE=`echo "$SCTL_MODULES" | grep "^$name \+|[^|]*| I"`
    if [ -z "$SCTL_MODULE" ]; then
        # install module with all its features
        INSTALL_MODULE "$i"
        continue
    fi

    sctl_revision=`echo "$SCTL_MODULE" | sed 's/[^|]*| \([^ ]*\).*/\1/'`
    revision=`echo "$i" | sed 's/[^@]*@\([^\.]*\).*/\1/'`
    if [ "$sctl_revision" \< "$revision" ]; then
        # update module without any features
        file=`echo "$i" | cut -d' ' -f 1`
        UPDATE_MODULE $file
    fi

    # parse sysrepoctl features and add extra space at the end for easier matching
    sctl_features="`echo "$SCTL_MODULE" | sed 's/\([^|]*|\)\{6\}\(.*\)/\2/'` "
    # parse features we want to enable
    features=`echo "$i" | sed 's/[^ ]* \(.*\)/\1/'`
    while [ "${features:0:3}" = "-e " ]; do
        # skip "-e "
        features=${features:3}
        # parse feature
        feature=`echo "$features" | sed 's/\([^[:space:]]*\).*/\1/'`

        # enable feature if not already
        sctl_feature=`echo "$sctl_features" | grep " ${feature} "`
        if [ -z "$sctl_feature" ]; then
            # enable feature
            ENABLE_FEATURE $name $feature
        fi

        # next iteration, skip this feature
        features=`echo "$features" | sed 's/[^[:space:]]* \(.*\)/\1/'`
    done
done
