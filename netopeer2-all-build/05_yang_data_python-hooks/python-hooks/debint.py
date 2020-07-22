#!/usr/bin/env python3
from __future__ import print_function
import debinterface
import time

"""
def debint_pre_parse_intf_name(intf_name, ip_addr_index):
    '''We use interface aliasing allows one interface to have multiple IP addresses. 
    Alias interfaces have names of the form interface:integer.
    When 
        ip_addr_index=1, return original interface name.
        Others, return form as "intf_name:ip_addr_index".
    '''
    if ( ip_addr_index == "1" ):
        return intf_name
    else:
        return "{}:{}".format(intf_name, ip_addr_index)
"""

def debint_create(opts_intf_name,   \
opts_addrFam="inet", opts_source="manual", opts_auto=True, opts_hotplug=False, \
opts_up=None, opts_down=None, \
opts_broadcast=None, opts_network=None,\
opts_gateway=None, opts_netmask=None, opts_address=None):

    if opts_auto == opts_hotplug:
        print("\t debint_create() failed, opts_auto and opts_hotplug MUST mutual exclusion: opts_auto:{}, opts_hotplug:{}".format(opts_auto, opts_hotplug))
        return -1

    def_opts = {
        'name': '',
        'addrFam': '',
        'source': '',
        'auto': '',
        'hotplug': '',
        'up':[],
        'down':[]
    }
    if opts_intf_name != None:
        def_opts["name"] = str(opts_intf_name)

    if opts_addrFam != None:
        def_opts["addrFam"] = str(opts_addrFam)

    if opts_source != None:
        def_opts["source"] = str(opts_source)

    if opts_auto != None:
        def_opts["auto"] = opts_auto

    if opts_hotplug != None:
        def_opts["hotplug"] = opts_hotplug
    ###########################################
    if opts_up != None:
        def_opts["up"] = opts_up

    if opts_down != None:
        def_opts["down"] = opts_down

    if opts_broadcast != None:
        def_opts["broadcast"] = str(opts_broadcast)

    if opts_network != None:
        def_opts["network"] = str(opts_network)

    if opts_gateway!= None:
        def_opts["gateway"] = str(opts_gateway)

    if opts_netmask != None:
        def_opts["netmask"] = str(opts_netmask)

    if opts_address != None:
        def_opts["address"] = str(opts_address)

    #print("repr(def_opts):{}".format(repr(def_opts)))
    itfs = debinterface.Interfaces()
    itfs.addAdapter(def_opts)
    itfs.writeInterfaces()

def debint_del(intf_name):
    itfs = debinterface.Interfaces()
    itfs.removeAdapterByName(str(intf_name))
    itfs.writeInterfaces() 

def debint_setGateway(intf_name, gateway):
    itfs = debinterface.Interfaces()
    adapter = itfs.getAdapter(str(intf_name))
    adapter.setGateway(str(gateway))
    itfs.writeInterfaces() 

def main():
    intf_name="eth0:999"
    print(intf_name)
    debint_create(intf_name)
    time.sleep(5)
    debint_del(intf_name)

    intf_name="eth0:888"
    print(intf_name)
    debint_create(intf_name, opts_addrFam="inet", opts_source="static", opts_auto=True, opts_address="192.168.88.60", opts_netmask="255.255.255.0", opts_network="192.168.88.0")
    time.sleep(5)
    debint_del(intf_name)

################################################################################
# Fake main()
if __name__ == '__main__':
    main()
else:
    # Initialize for import as module
    pass
################################################################################
