FROM ubuntu:focal

WORKDIR /opt/cuberite

RUN apt update && apt install -y \
    curl gettext-base openssl && \
    curl -sSfL https://download.cuberite.org | sh && \
    rm -rf /var/lib/apt/lists/*
    
ENV CUBERITE_USERNAME="admin" \
    CUBERITE_PASSWORD="cuberite" \
    PGID="46372" \
    PUID="46372"
    
WORKDIR /cuberite

COPY entrypoint.sh    /entrypoint.sh
COPY webadmin.ini.tpl /opt/webadmin.ini.tpl

VOLUME /cuberite

EXPOSE 8080 25565

ENTRYPOINT ["/entrypoint.sh", "/cuberite/Cuberite"]
