#!/bin/bash
#Install the Starbound dedicated server
/steamcmd/steamcmd.sh \
    +force_install_dir /vrising/ \
    +login anonymous \
    +app_update 1829350 validate \
    +quit

#Run the server
cd /vrising/linux
./vrising

exit
