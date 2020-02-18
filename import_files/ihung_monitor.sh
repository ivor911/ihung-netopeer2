#!/bin/bash

NOW_ADDR="0"
PREV_ADDR="0"
INT=$1

update_ip()
{
	#XPATH_IP=`./sr_get_items_example "/ietf-interfaces:interfaces/interface[name='eth2']/ietf-ip:ipv4/address/*"  running  | awk -F "ip = " '/1/ {print $2}' |  awk NF`
	#XPATH_PREFIX=`./sr_get_items_example "/ietf-interfaces:interfaces/interface[name='eth2']/ietf-ip:ipv4/address/*"  running  | awk -F "prefix-length = " '/1/ {print $2}' |  awk NF`
	#echo "${XPATH_IP}/${XPATH_PREFIX}" > ./ip.txt

    ./call-sr_get_items_example.sh
	NOW_ADDR="`cat ip.txt`"
}

ip_addr_reset() {
## reset ip address
	echo
	echo "--> Monitor: ip_addr_reset()... ${PREV_ADDR} -> ${NOW_ADDR}"
	ip addr delete ${PREV_ADDR} dev ${INT}
	ip addr add ${NOW_ADDR} dev ${INT}
}

ip_changed() {
	echo "--> Monitor: ip.txt changed, do ip_addr_reset()..."
	ip_addr_reset
	PREV_ADDR=${NOW_ADDR}
}

ip_compare() {
   if [ ${NOW_ADDR} != "0" ] && [ ${PREV_ADDR} != "0" ]
   then
        update_ip
        if [ "${NOW_ADDR}" != "${PREV_ADDR}" ]
        then
            ip_changed
        fi
   else
        NOW_ADDR="`cat ip.txt`"
        PREV_ADDR="`cat ip.txt`"
   fi
}

run() {
	while true; do
		ip_compare
		sleep 1
	done
}

echo "--> Monitor: ip.txt ..."
run



