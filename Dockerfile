FROM alpine as downloader

COPY files/easyinstall.sh /opt/cuberite/easyinstall.sh

RUN  cd /opt/cuberite && /opt/cuberite/easyinstall.sh


FROM ubuntu as cuberite

RUN apt update && apt -y install \
       curl gettext-base openssl  && \
    rm -rf /var/lib/apt/lists/*
        
ENV CUBERITE_USERNAME="admin" \
    CUBERITE_PASSWORD="cuberite" \
    PGID="46372" \
    PUID="46372" \
    HTTPS=1 \
    CREATE_SETTINGS_INI=0 \
    DEFAULT_LOGIN_PERMISSIONS=1 \
    AUTHENTICATION_AUTHENTICATE=1 \
    AUTHENTICATION_ALLOWBUNGEECORD=0 \
    AUTHENTICATION_SERVER='sessionserver.mojang.com' \
    AUTHENTICATION_ADDRESS='/session/minecraft/hasJoined?username=%USERNAME%&serverId=%SERVERID%' \
    MOJANGAPI_NAMETOUUIDSERVER='api.mojang.com' \
    MOJANGAPI_NAMETOUUIDADDRESS='/profiles/minecraft' \
    MOJANGAPI_UUIDTOPROFILESERVER='sessionserver.mojang.com' \
    MOJANGAPI_UUIDTOPROFILEADDRESS='/session/minecraft/profile/%UUID%?unsigned=false' \
    SERVER_DESCRIPTION='Cuberite - in C++!' \
    SERVER_SHUTDOWNMESSAGE='Server shutdown' \
    SERVER_MAXPLAYERS=100 \
    SERVER_HARDCOREENABLED=0 \
    SERVER_ALLOWMULTILOGIN=0 \
    SERVER_RESOURCEPACKURL='' \
    SERVER_PORTS=25565 \
    SERVER_ALLOWMULTIWORLDTABCOMPLETION=1 \
    SERVER_DEFAULTVIEWDISTANCE=10 \
    RCON_ENABLED=0 \
    ANTICHEAT_LIMITPLAYERBLOCKCHANGES=1 \
    PLAYERDATA_LOADOFFLINEPLAYERDATA=0 \
    PLAYERDATA_LOADNAMEDPLAYERDATA=1 \
    WORLDS_DEFAULTWORLD='world' \
    WORLDPATHS_WORLD='world' \
    PLUGINS_CORE=1 \
    PLUGINS_CHATLOG=1 \
    PLUGINS_PROTECTIONAREAS=0 \
    PLUGINS_LOGIN=0 \
    DEADLOCKDETECT_ENABLED=1 \
    DEADLOCKDETECT_INTERVALSEC=20

COPY --from=downloader /opt/cuberite/ /opt/cuberite/
    
COPY files/entrypoint.sh    /entrypoint.sh
COPY files/webadmin.ini.tpl /opt/webadmin.ini.tpl

VOLUME /cuberite

EXPOSE 8080 25565

ENTRYPOINT ["/entrypoint.sh", "/cuberite/Cuberite"]
