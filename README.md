![image build and push](https://github.com/mehmetahsen/cuberite-docker/workflows/image%20build%20and%20push/badge.svg?branch=master)
![release stable image](https://github.com/mehmetahsen/cuberite-docker/workflows/release%20stable%20image/badge.svg)

## [Cuberite](https://cuberite.org/) for whale and raspberry lovers

> Cuberite is a Free and Open Source (FOSS) Minecraft-compatible game server. Cuberite is designed with performance, configurability, and extensibility in mind, and also aims to accurately recreate most Minecraft features. 

Containers are cross built for armv7, so they run on Raspberry Pi too!

## How to run

Head to https://localhost:8080 for the webadmin panel.

Default username is `admin` and password is `cuberite` 

**Latest build** `mehmetahsen/cuberite:latest`

Check out GitHub Actions if you're interested. [.github/workflows/](.github/workflows/) and [mehmetahsen/cuberite-docker GitHub Actions](https://github.com/mehmetahsen/cuberite-docker/actions)

### Quick way

```bash
docker run --publish 8080:8080 --publish 25565:25565 --tty mehmetahsen/cuberite
```

###  :warning: **Make sure to change the password**


### Local mount

With your uid:gid, when you would like to edit/backup the config files with ease:

```bash
mkdir -p `pwd`/cuberite
export PUID=`id -u`
export PGID=`id -g`
docker run --name cuberite --publish 8080:8080 --publish 25565:25565 \
           --volume `pwd`/cuberite:/cuberite --detach --tty --restart unless-stopped \
           --env PUID --env PGID --env CUBERITE_USERNAME='admin' --env CUBERITE_PASSWORD='cuberite' mehmetahsen/cuberite
```

### Docker managed volume

```bash
docker run --name cuberite --publish 8080:8080 --publish 25565:25565 \
            --volume cuberite:/cuberite --detach --tty --restart unless-stopped \
            --env CUBERITE_USERNAME='admin' --env CUBERITE_PASSWORD='cuberite' mehmetahsen/cuberite
```

### docker-compose.yml
```yaml
cuberite:
  image: mehmetahsen/cuberite
  environment:
    - CUBERITE_USERNAME=admin
    - CUBERITE_PASSWORD=cuberite
  volumes:
    - /mnt/cuberite:/cuberite
  ports:
    - 8080:8080
    - 25565:25565
  tty: true
  restart: unless-stopped
```

## Options

`CREATE_SETTINGS_INI` will turn off online-mode, activate Login plugin plugin with permissive defaults. It doesn't do anything if `settings.ini` already exists.


Environment variable | Default | Description
--- | --- | ---
CUBERITE_USERNAME | admin | Username for the Cuberite admin webpanel.
CUBERITE_PASSWORD | cuberite | Password for the Cuberite admin webpanel.
PUID | 46372 | Linux uid cuberite should run with inside the container. Has implications when using local mount for `/cuberite`.
PGID | 46372 | Linux gid cuberite should run with inside the container. Has implications when using local mount for `/cuberite`.
HTTPS | 1 | Enables HTTPS with self-signed certs.
DEFAULT_LOGIN_PERMISSIONS | 1 | Will allow anyone to register&login via Login plugin. Needs PLUGINS_LOGIN=1
CREATE_SETTINGS_INI | 0 | Will create a settings.ini file, if it didn't exist. All options below require this.

Below options are from `settings.ini`, wherein format is `SECTION_KEY`. It's **not** a dynamic mapping.
Environment variable | Default | Description
--- | --- | ---
AUTHENTICATION_AUTHENTICATE | 1 | Online/offline mode
AUTHENTICATION_ALLOWBUNGEECORD | 0 | 
AUTHENTICATION_SERVER | 'sessionserver.mojang.com' | 
AUTHENTICATION_ADDRESS | '/session/minecraft/hasJoined?username | %USERNAME%&serverId | %SERVERID%' | 
MOJANGAPI_NAMETOUUIDSERVER | 'api.mojang.com' | 
MOJANGAPI_NAMETOUUIDADDRESS | '/profiles/minecraft' | 
MOJANGAPI_UUIDTOPROFILESERVER | 'sessionserver.mojang.com' | 
MOJANGAPI_UUIDTOPROFILEADDRESS | '/session/minecraft/profile/%UUID%?unsigned | false' | 
SERVER_DESCRIPTION | 'Cuberite - in C++!' | Server description.
SERVER_SHUTDOWNMESSAGE | 'Server shutdown' | Server shutdown message.
SERVER_MAXPLAYERS | 100 | Maximum number of players allowed.
SERVER_HARDCOREENABLED | 0 | 
SERVER_ALLOWMULTILOGIN | 0 | 
SERVER_RESOURCEPACKURL | '' | 
SERVER_PORTS | 25565 | 
SERVER_ALLOWMULTIWORLDTABCOMPLETION | 1 | 
SERVER_DEFAULTVIEWDISTANCE | 10 | 
RCON_ENABLED | 0 | 
ANTICHEAT_LIMITPLAYERBLOCKCHANGES | 1 | 
PLAYERDATA_LOADOFFLINEPLAYERDATA | 0 | 
PLAYERDATA_LOADNAMEDPLAYERDATA | 1 | 
WORLDS_DEFAULTWORLD | 'world' | 
WORLDPATHS_WORLD | 'world' | 
PLUGINS_CORE | 1 | Enable core
PLUGINS_CHATLOG | 1 | Enable chatlog
PLUGINS_PROTECTIONAREAS | 0 | Enable protection areas
PLUGINS_LOGIN | 0 | Enable Login
DEADLOCKDETECT_ENABLED | 1 | 
DEADLOCKDETECT_INTERVALSEC | 20 | 

## Architecture

Cubernite architecture makes it hard to containerize. [Issue 3426](https://github.com/cuberite/cuberite/issues/3426)

As a workaround, cuberite is installed to `/opt/cuberite` but actually runs at `/cuberite`. Everything else is then copied to `/cuberite`. Binary, README, LICENSE, CONTRIBUTORS is linked back to `/opt/cuberite`. This offers a degree of seperation though far from ideal. It could brake your setup.

`/cuberite` is the volume for this container. Everything that needs persisting should have a copy there. If you find something missing, let me know.

Container does use `root` for Dockerfile, but it does so for being able to run as with a given `uid:gid`, helping with local mounts. It drops the privileges after creating the user:group and setting appropriate permissions. Default `uid:gid` is `46372:46372`. If you don't care for local fs mounts, then you probably don't need these. Do **NOT run it as root**.

`entrypoint.sh` is called twice on each run, one as `root`, and another one after privilege drop. First run is to create cuberite user & group with given `uid:gid`, second run is for copying config files, etc. to the `/cuberite` mount, and finally to run cuberite. `entrypoint.sh` shouldn't change anything in `/cuberite` but it should re-create the default files if they're missing.


## Building

Several aliases are in `env.sh`. If you like to use them just source the file in your shell: ` . env.sh `

```
export DOCKER_BUILDKIT=1
alias konbuild='docker build --tag cuberite .'
alias konfol='docker logs --follow cuberite'
alias konrun='docker run --name cuberite --publish 8080:8080 --publish 25565:25565 --volume cuberite:/cuberite --detach --tty cuberite'
alias konrunmount='docker run --name cuberite --publish 8080:8080 --publish 25565:25565 --volume `pwd`/cuberite:/cuberite --detach --tty cuberite'
alias konrm='docker container rm --force --volumes cuberite'
alias konsh='docker exec --tty --interactive cuberite /bin/bash'
alias konoverrun='konrm && konbuild && konrun && konfol'
alias konprune='docker kill $(docker ps -a -q) || docker container prune --force && docker system prune --force --all --volumes'
```
