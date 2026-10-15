#!/bin/sh
for attempt in 1 2 3; do
    /steamcmd/steamcmd.sh \
        +@sSteamCmdForcePlatformType windows \
        +force_install_dir /vrising/ \
        +login anonymous \
        +app_update 1829350 validate \
        +quit && break
    echo "steamcmd failed (attempt $attempt), retrying..."
done

if [ ! -f /vrising/VRisingServer.exe ]; then
    echo "VRisingServer.exe not found after install, exiting"
    exit 1
fi

cd /vrising

exec 3>&1
script -qfec "wine VRisingServer.exe -persistentDataPath Z:/serverData >&3 2>&1" /dev/null </dev/null &
SERVER_PID=$!

cleanup() {
    wineserver -k
}

shutdown() {
    echo "Received stop signal, shutting down V Rising server..."
    pkill -INT -f '^VRisingServer.exe'
    wait "$SERVER_PID"
    cleanup
    exit 0
}
trap shutdown TERM INT

wait "$SERVER_PID"
EXIT_CODE=$?
cleanup
exit $EXIT_CODE
