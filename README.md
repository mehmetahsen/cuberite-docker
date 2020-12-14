__Yet another fork. Might not be ready, use at your risk.__

## [Cuberite](https://cuberite.org/) for whale lovers

> Cuberite is a Free and Open Source (FOSS) Minecraft-compatible game server. Cuberite is designed with performance, configurability, and extensibility in mind, and also aims to accurately recreate most Minecraft features.

## How to run

Head to https://localhost:8080 for the webadmin panel.

Default username is `admin` and password is `cuberite` 

### Quick way

```bash
docker run --publish 8080:8080 --publish 25565:25565 --tty cuberite
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
           --env PUID --env PGID --env CUBERITE_USERNAME='admin' --env CUBERITE_PASSWORD='cuberite' cuberite
```

### Docker managed volume

```bash
docker run --name cuberite --publish 8080:8080 --publish 25565:25565 \
            --volume cuberite:/cuberite --detach --tty --restart unless-stopped \
            --env CUBERITE_USERNAME='admin' --env CUBERITE_PASSWORD='cuberite' cuberite
```

## Options

- `CUBERITE_USERNAME`="admin"  Username for the Cuberite admin webpanel.

- `CUBERITE_PASSWORD`="cuberite" Password for the Cuberite admin webpanel.

- `PUID`="46372" Linux uid cuberite should run with inside the container. Has implications when using local mount for `/cuberite`.

- `PGID`="46372" Linux gid cuberite should run with inside the container. Has implications when using local mount for `/cuberite`.

- `NOHTTPS`: When defined, it won't generate cert pair, even if they don't exist. Default behaviour is to generate self-signed certs and enable HTTPS only.

- `files/guest.html`: If you like to change the greeting for webadmin panel, head to this file.


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
