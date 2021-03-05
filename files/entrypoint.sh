#!/bin/sh

# Exit on error, print extra
set -ex

# nofail functions for the config copy
# we copy/link them only if it doesn't exist
cpnofail() { cp -r  $1 $2 || true; return 0; }
lnnofail() { ln -s $1 $2 || true; return 0; }
settings_ini() {
cat <<EOF > settings.ini
[Authentication]
Authenticate=$AUTHENTICATION_AUTHENTICATE
AllowBungeeCord=$AUTHENTICATION_ALLOWBUNGEECORD
Server=$AUTHENTICATION_SERVER
Address=$AUTHENTICATION_ADDRESS

[MojangAPI]
NameToUUIDServer=$MOJANGAPI_NAMETOUUIDSERVER
NameToUUIDAddress=$MOJANGAPI_NAMETOUUIDADDRESS
UUIDToProfileServer=$MOJANGAPI_UUIDTOPROFILESERVER
UUIDToProfileAddress=$MOJANGAPI_UUIDTOPROFILEADDRESS

[Server]
Description=$SERVER_DESCRIPTION
ShutdownMessage=$SERVER_SHUTDOWNMESSAGE
MaxPlayers=$SERVER_MAXPLAYERS
HardcoreEnabled=$SERVER_HARDCOREENABLED
AllowMultiLogin=$SERVER_ALLOWMULTILOGIN
ResourcePackUrl=$SERVER_RESOURCEPACKURL
Ports=$SERVER_PORTS
AllowMultiWorldTabCompletion=$SERVER_ALLOWMULTIWORLDTABCOMPLETION
DefaultViewDistance=$SERVER_DEFAULTVIEWDISTANCE

[RCON]
Enabled=$RCON_ENABLED

[AntiCheat]
LimitPlayerBlockChanges=$ANTICHEAT_LIMITPLAYERBLOCKCHANGES

[PlayerData]
LoadOfflinePlayerData=$PLAYERDATA_LOADOFFLINEPLAYERDATA
LoadNamedPlayerData=$PLAYERDATA_LOADNAMEDPLAYERDATA

[Worlds]
DefaultWorld=$WORLDS_DEFAULTWORLD

[WorldPaths]
world=$WORLDPATHS_WORLD

[Plugins]
Core=$PLUGINS_CORE
ChatLog=$PLUGINS_CHATLOG
ProtectionAreas=$PLUGINS_PROTECTIONAREAS
Login=$PLUGINS_LOGIN

[DeadlockDetect]
Enabled=$DEADLOCKDETECT_ENABLED
IntervalSec=$DEADLOCKDETECT_INTERVALSEC
EOF
}
add_default_group_permission() {
  curl --silent --output /dev/null --insecure --user "${CUBERITE_USERNAME}:${CUBERITE_PASSWORD}" -H 'Content-Type: application/x-www-form-urlencoded'  --data-raw "Permission=$1&subpage=addpermission&GroupName=Default" "$BASE_URL/webadmin/Core/Permissions" --output /dev/null
}

reload_server() {
  curl --silent --output /dev/null --insecure --user "${CUBERITE_USERNAME}:${CUBERITE_PASSWORD}" -H 'Content-Type: application/x-www-form-urlencoded' --data-raw 'ReloadServer=Reload+Server' "$BASE_URL/webadmin/Core/Manage+Server"
}
default_login_permissions() {
  # poll till cuberite is up
  echo 'Update login permissions: Waiting for cuberite...'
  while ! curl --insecure --silent --head --fail --output /dev/null $BASE_URL; do
    sleep 1
  done
  echo 'Update login permissons: Cuberite is up, updating permissions with default login policy.'
  # cuberite is up!
  for permission in login.changepass login.login login.register; do
    add_default_group_permission $permission
  done
  echo 'Update login permissons: Permissions updated, will reload the server.'
  reload_server
  echo 'Update login permissons: Done.'
}

if [ "$(id cuberite --user)" != "$PUID" ]; then # As root. cuberite user wasn't created yet

  # Preperation, create user/group with given uid:gid. 
  addgroup --system --gid $PGID cuberite
  adduser --system --disabled-password  --disabled-login --no-create-home --uid $PUID --gid $PGID cuberite

  # Required for changes on /webadmin for guest.html editing and HTTPS cert/key deploy.
  chown cuberite:cuberite --recursive /opt/cuberite

  # Prepare working dir
  chown cuberite:cuberite --recursive /cuberite
    
  # Drop privileges
  exec su --preserve-environment --shell /bin/sh --command "/entrypoint.sh $@" cuberite
  
else # After dropping root

  # Go to working dir 
  cd /cuberite
  
  # Template webadmin.ini if one doesn't exist already
  if [ ! -f webadmin.ini ]; then
    cat<<EOF > webadmin.ini
[User:${CUBERITE_USERNAME}]
Password=${CUBERITE_PASSWORD}

[WebAdmin]
Enabled=1
Ports=8080
EOF
  fi  
  # File contains password, shouldn't be readable by others
  chmod 640 webadmin.ini
  
  # Check if we have https cert & key, if not, generate one
  if [ $HTTPS -eq 1 ]; then
    export PROTOCOL='https'
    if [ ! -f https/httpscert.crt -o ! -f https/httpskey.pem ]; then
        echo "Couldn't find cert and/or key, generating a pair."
        mkdir -p https
        openssl req -x509 -newkey rsa:2048 -keyout https/httpskey.pem -out https/httpscert.crt \
                        -days 3650 -nodes -subj "/C=DE/"
    else
        echo "Found cert & key, no need to generate one. "
    fi
    echo "Linking cert & key to the mount."
    lnnofail /cuberite/https/httpscert.crt /opt/cuberite/webadmin/
    lnnofail /cuberite/https/httpskey.pem  /opt/cuberite/webadmin/
  else
    export PROTOCOL='http'
    echo "HTTPS is not set, skipping cert generation."
  fi

  export BASE_URL="${PROTOCOL}://localhost:8080"

  # For webadmin/files/guest.html file only
  mkdir -p files

  # Links and copies
  lnnofail /opt/cuberite/BACKERS      .
  lnnofail /opt/cuberite/CONTRIBUTORS .
  lnnofail /opt/cuberite/Cuberite     .
  lnnofail /opt/cuberite/webadmin     .
  lnnofail /opt/cuberite/LICENSE      .
  lnnofail /opt/cuberite/README.txt   .
  lnnofail /opt/cuberite/ThirdPartyLicenses .
  cpnofail '/opt/cuberite/*'      .
  cpnofail /opt/cuberite/webadmin/files/guest.html /cuberite/files/guest.html
  ln -sf /cuberite/files/guest.html /opt/cuberite/webadmin/files/guest.html #overwrite the original file

  if [ $CREATE_SETTINGS_INI -eq 1 ]; then
    echo "CREATE_SETTINGS_INI option set, creating settings.ini"
    if [ -f settings.ini ]; then
      echo "A settings.ini file already exists, not touching."
    else
      settings_ini
    fi
  fi
  
  if [ $DEFAULT_LOGIN_PERMISSIONS -eq 1 -a $PLUGINS_LOGIN -eq 1 ]; then
    echo "Updating default login permissions, anyone can register, login and change their password."
    default_login_permissions &
  fi
  
  # Run
  exec $@
fi
