#!/bin/sh
/steamcmd/steamcmd.sh \
    +@sSteamCmdForcePlatformType windows \
    +force_install_dir /vrising/ \
    +login anonymous \
    +app_update 1829350 validate \
    +quit

cd /vrising

xvfb-run -a wine64 VRisingServer.exe -persistentDataPath Z:/serverData