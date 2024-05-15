#!/bin/sh
#Install the vrising dedicated server
/steamcmd/steamcmd.sh \
    +@sSteamCmdForcePlatformType windows \
    +force_install_dir /vrising/ \
    +login anonymous \
    +app_update 1829350 validate \
    +quit

#Run the server
cd /vrising

Xvfb :0 -screen 0 1024x768x16 &
DISPLAY=:0.0 wine64 VRisingServer.exe -persistentDataPath Z:\\serverData

exit
