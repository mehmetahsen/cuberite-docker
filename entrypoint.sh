#!/bin/sh

# Exit on error, print extra
set -ex

# nofail functions for the config copy
# we copy/link them only if it doesn't exist
cpnofail() { cp -r  $1 $2 || true; return 0; }
lnnofail() { ln -s $1 $2 || true; return 0; }

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
    envsubst < /opt/webadmin.ini.tpl > webadmin.ini
  fi  
  # File contains password, shouldn't be readable by others
  chmod 640 webadmin.ini
  
  # Check if we have https cert & key, if not, generate one
  if [ -z "$NOHTTPS" ]; then 
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
    echo "NOHTTPS is set, skipping cert generation."
  fi

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

  # Run
  exec $@
fi
