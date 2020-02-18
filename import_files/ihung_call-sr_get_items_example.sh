#!/bin/bash
./sr_get_items_example "/ietf-interfaces:interfaces/interface[name='eth2']/ietf-ip:ipv4/address/*"  running  | awk -F "ip = " '/1/ {print $2}' |  awk NF | xargs echo -n > ip.txt
echo -n "/" >> ip.txt
./sr_get_items_example "/ietf-interfaces:interfaces/interface[name='eth2']/ietf-ip:ipv4/address/*"  running  | awk -F "prefix-length = " '/1/ {print $2}' |  awk NF >> ip.txt
