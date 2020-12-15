FROM ubuntu:focal

RUN apt update && apt install -y \
    wget gettext-base openssl && \
    rm -rf /var/lib/apt/lists/*

COPY files/easyinstall.sh /opt/cuberite/easyinstall.sh
    
RUN  cd /opt/cuberite && /opt/cuberite/easyinstall.sh
    
ENV CUBERITE_USERNAME="admin" \
    CUBERITE_PASSWORD="cuberite" \
    PGID="46372" \
    PUID="46372"
    
WORKDIR /cuberite

COPY files/entrypoint.sh    /entrypoint.sh
COPY files/webadmin.ini.tpl /opt/webadmin.ini.tpl

VOLUME /cuberite

EXPOSE 8080 25565

ENTRYPOINT ["/entrypoint.sh", "/cuberite/Cuberite"]
