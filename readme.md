# AzureOwl/vrising-server

Dockerized vrising dedicated server

# How to use

The preferred way to use this image is docker-compose:

```yaml
services:
  vrising_server:
    image: azureowl/vrising:latest
    container_name: vrising
    ports:
      - 27015:27015/udp
      - 27016:27016/udp
    volumes:
      - /path/to/game/files:/vrising
      - /path/to/config/files:/serverData
    environment:
      - UID=1000
      - GID=1000
    restart: unless-stopped
```

# Running the container

Before running the container first create the folder containing the volume and assign ownership to the UID and GID you enter into the `docker-compose` file.

```shell
sudo mkdir -p /opt/vrising
sudo chown 1000:1000 /opt/vrising
```
The `chown` command is required because server is not run as root but as the vrising user with default user id 1000. The same write permissions must also be present on the host folder.

Furthermore a folder to contain the game files and a separate folder for the config files need to be created with the same ownership permissions.

Inside the config file folder create the "Saves" and "Settings" folder. Copy your ServerGameSettings.json and ServerHostSettings.json files to this folder to configure your server.

Launch the container with 

```shell
docker-compose -f vrising.yml up -d
```

# Editing server config

To configure your server edit the ServerHostSettings.json and ServerGameSettings.json files in the Settings folder. Example values for these files can be found on the official V Rising dedicated server github.

After editing these files, restart the container for the changes to take effect.
