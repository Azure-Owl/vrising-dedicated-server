# AzureOwl/vrising-dedicated-server

Dockerized vrising dedicated server

# How to use

The preferred way to use this image is docker-compose:

```yaml
services:
  vrising_server:
    image: azureowl/vrising-dedicated-server:latest
    container_name: vrising
    ports:
      - 27015:27015/udp
      - 27016:27016/udp
    volumes:
      - /path/to/game/files:/vrising
      - /path/to/config/files:/serverData
    stop_grace_period: 2m
    restart: unless-stopped
```

# Running the container

Before running the container first create the folder containing the volume and assign ownership to UID and GID 1000.

```shell
sudo mkdir -p /opt/vrising
sudo chown 1000:1000 /opt/vrising
```
The `chown` command is required because server is not run as root but as the vrising user with default user id 1000. The same write permissions must also be present on the host folder.

To run as a different user, build the image with your own IDs:

```shell
docker build --build-arg UID=1001 --build-arg GID=1001 -t vrising-dedicated-server .
```

Furthermore a folder to contain the game files and a separate folder for the config files need to be created with the same ownership permissions.

Inside the config file folder create the "Saves" and "Settings" folder. Copy your ServerGameSettings.json and ServerHostSettings.json files to this folder to configure your server.

Launch the container with 

```shell
docker-compose -f vrising.yml up -d
```

# Editing server config

To configure your server edit the ServerHostSettings.json and ServerGameSettings.json files in the Settings folder. Example values for these files can be found on the official V Rising dedicated server github.

After editing these files, restart the container for the changes to take effect.

When the container is stopped, the server is sent a shutdown signal so it can save the world before exiting. `stop_grace_period` gives it time to finish; without it Docker kills the server after 10 seconds.

# Skipping updates

On every start the container updates the server to the latest version. Set `SKIP_UPDATE=true` to start the installed version without checking for updates, for example to wait for mods to update after a patch. Remove it again to update. The installed build is printed in the log at startup.

# Overriding host settings with environment variables

Any setting in `ServerHostSettings.json` can also be set with an environment variable. The V Rising server reads these itself, so no file edits are needed. Environment variables take precedence over the values in `ServerHostSettings.json`, so only set the ones you want to override.

| Variable | Setting | Type | Example |
|---|---|---|---|
| `VR_NAME` | Name | text | `My V Rising Server` |
| `VR_DESCRIPTION` | Description | text | `Reset every Monday. Be nice.` |
| `VR_GAME_PORT` | Port | number | `27015` |
| `VR_QUERY_PORT` | QueryPort | number | `27016` |
| `VR_ADDRESS` | Address | text | `10.20.0.3` |
| `VR_HIDE_IP_ADDRESS` | HideIPAddress | boolean | `true` |
| `VR_MAX_USERS` | MaxConnectedUsers | number | `40` |
| `VR_MAX_ADMINS` | MaxConnectedAdmins | number | `4` |
| `VR_FPS` | ServerFps | number | `30` |
| `VR_LOWER_FPS_WHEN_EMPTY` | LowerFPSWhenEmpty | boolean | `true` |
| `VR_LOWER_FPS_WHEN_EMPTY_VALUE` | LowerFPSWhenEmptyValue | number | `10` |
| `VR_PASSWORD` | Password | text | `SuperSecret` |
| `VR_SECURE` | Secure | boolean | `true` |
| `VR_LIST_ON_EOS` | ListOnEOS | boolean | `true` |
| `VR_LIST_ON_STEAM` | ListOnSteam | boolean | `true` |
| `VR_PRESET` | GameSettingsPreset | text | `StandardPvP` |
| `VR_DIFFICULTY_PRESET` | GameDifficultyPreset | text | `Difficulty_Normal` |
| `VR_SAVE_NAME` | SaveName | text | `world1` |
| `VR_SAVE_COUNT` | AutoSaveCount | number | `20` |
| `VR_SAVE_INTERVAL` | AutoSaveInterval | number | `120` |
| `VR_AUTOSAVESMARTKEEP` | AutoSaveSmartKeep | text | `10:1:1,30:0:1,60:0:1` |
| `VR_LAN_MODE` | LanMode | boolean | `false` |
| `VR_RESET_DAYS_INTERVAL` | ResetDaysInterval | number | `0` |
| `VR_DAY_OF_RESET` | DayOfReset | enum | `Any`, `Monday` … `Sunday` |
| `VR_SAFE_RECONNECT_TIME` | SafeReconnectTime | number | `300` |
| `VR_SAFE_RECONNECT_SLOTS` | SafeReconnectSlots | number | `10` |
| `VR_RCON_ENABLED` | Rcon.Enabled | boolean | `false` |
| `VR_RCON_PORT` | Rcon.Port | number | `25575` |
| `VR_RCON_PASSWORD` | Rcon.Password | text | `ExtraSecretPassword` |
| `VR_RCON_BIND_ADDRESS` | Rcon.BindAddress | text | `10.22.0.8` |

If you change `VR_GAME_PORT`, `VR_QUERY_PORT` or `VR_RCON_PORT`, update the published ports to match. RCON uses TCP; the game and query ports use UDP.
