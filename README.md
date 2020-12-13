**Yet another fork. Not ready, use at your risk.**

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
