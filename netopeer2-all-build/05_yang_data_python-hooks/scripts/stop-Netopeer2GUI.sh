#!/bin/bash
BACKEND_PID=`ps aux | grep "python3 backend" | grep -v grep | awk '{print $2}'`
FRONTEND_PID=`ps aux | grep "ng serve" | grep -v grep | awk '{print $2}'`
kill -9 ${BACKEND_PID}
kill -9 ${FRONTEND_PID}
