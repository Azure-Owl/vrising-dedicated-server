# AzureOwl/vrising-server

Dockerized vrising dedicated server

# How to use

The preferred way to use this image is docker-compose:

```yaml
version: '2'
  services:
    vrising-server:
      image: azureowl/vrising-server
      container_name: vrising
      environment:
        - UID=1000
        - GID=1000
      volumes:
        - /path/to/folder:/vrising
      ports:
        - 27015:27015/udp #default game port
        - 27016:27016/udp #default game port
      restart: unless-stopped
```

