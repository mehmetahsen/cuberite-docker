FROM alpine as downloader

COPY files/easyinstall.sh /opt/cuberite/easyinstall.sh

RUN  cd /opt/cuberite && /opt/cuberite/easyinstall.sh


FROM ubuntu as cuberite

RUN apt update && apt -y install \
       gettext-base openssl  && \
    rm -rf /var/lib/apt/lists/*
        
ENV CUBERITE_USERNAME="admin" \
    CUBERITE_PASSWORD="cuberite" \
    PGID="46372" \
    PUID="46372"

COPY --from=downloader /opt/cuberite/ /opt/cuberite/
    
COPY files/entrypoint.sh    /entrypoint.sh
COPY files/webadmin.ini.tpl /opt/webadmin.ini.tpl

VOLUME /cuberite

EXPOSE 8080 25565

ENTRYPOINT ["/entrypoint.sh", "/cuberite/Cuberite"]
