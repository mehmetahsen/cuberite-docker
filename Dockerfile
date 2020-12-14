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
    
#RUN addgroup --system --gid $PGID cuberite && \
#    adduser --system --disabled-password  --disabled-login --no-create-home --uid $PUID --gid $PGID cuberite && \
#    chown cuberite:cuberite -R . 

#USER cuberite

WORKDIR /cuberite

#COPY --chown=cuberite:cuberite  entrypoint.sh    /entrypoint.sh
#COPY --chown=cuberite:cuberite  webadmin.ini.tpl /cuberite/webadmin.ini.tpl

COPY entrypoint.sh    /entrypoint.sh
COPY webadmin.ini.tpl /opt/webadmin.ini.tpl

#RUN envsubst < /cuberite/webadmin.ini.tpl > /cuberite/webadmin.ini

VOLUME /cuberite

EXPOSE 8080 25565

ENTRYPOINT ["/entrypoint.sh", "/cuberite/Cuberite"]
