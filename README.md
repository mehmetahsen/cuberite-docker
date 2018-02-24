[![Travis](https://shields.beevelop.com/travis/beevelop/docker-cuberite.svg?style=flat-square)](https://travis-ci.org/beevelop/docker-cuberite)
[![Pulls](https://shields.beevelop.com/docker/pulls/beevelop/cuberite.svg?style=flat-square)](https://links.beevelop.com/d-cuberite)
[![Layers](https://shields.beevelop.com/docker/image/layers/beevelop/cuberite/latest.svg?style=flat-square)](https://links.beevelop.com/d-cuberite)
[![Size](https://shields.beevelop.com/docker/image/size/beevelop/cuberite/latest.svg?style=flat-square)](https://links.beevelop.com/d-cuberite)
[![GitHub release](https://shields.beevelop.com/github/release/beevelop/docker-cuberite.svg?style=flat-square)](https://github.com/beevelop/docker-cuberite/releases)
![Badges](https://shields.beevelop.com/badge/badges-7-brightgreen.svg?style=flat-square)
[![Beevelop](https://links.beevelop.com/honey-badge)](https://beevelop.com)

# [Cuberite](https://cuberite.org/) for whale lovers

> Cuberite is a Free and Open Source (FOSS) Minecraft-compatible game server. Cuberite is designed with performance, configurability, and extensibility in mind, and also aims to accurately recreate most Minecraft features.

## Quickstart
```bash
docker run --tty -d --name="cuberite" -p 8080:8080 -p 25565:25565 beevelop/cuberite
```

The server should be accessible via Port `25565`. There is a webadmin interface available at `8080` (default login `admin` and password `Swordfish`).

## Configuration
- `ADMIN_USERNAME` (default: `admin`): The username for the webadmin interface
- `ADMIN_PASSWORD` (default: `Swordfish`): The password for the webadmin interface
- `MAX_PLAYERS` (default: `30`): Max. amount of players

Both values can be changed and will be written to the `webadmin.ini` file on launch (this does effectively override the `webadmin.ini` on every start).

## Folders of interest
All necessary file are located at `/opt/cuberite`. 

## Troubleshooting
Feel free to open an issue on GitHub if you encounter any problems with this Docker image.
