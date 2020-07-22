#!/bin/bash

#start backend
cd /liberouter-gui
source venv/bin/activate
python3 backend > backend.log 2>&1 &
deactivate
cd ..

#stop frontend
cd /liberouter-gui/frontend
/usr/local/bin/ng serve --host 0.0.0.0 --proxy-config proxy.json > ../frontend.log 2>&1 &
cd ../..
