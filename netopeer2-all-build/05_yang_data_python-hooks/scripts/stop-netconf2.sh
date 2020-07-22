#!/bin/bash
#SYSREPO_PLUGIND_PID=`ps aux | grep sysrepo-plugind | grep -v grep | awk '{print $2}'`
NETOPEER2_SERVER_PID=`ps aux | grep netopeer2-server | grep -v grep | awk '{print $2}'`
#kill -9 ${SYSREPO_PLUGIND_PID}
kill -9 ${NETOPEER2_SERVER_PID}
