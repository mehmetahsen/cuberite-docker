FROM node:lts-buster

WORKDIR /bot

RUN npm install mineflayer prismarine-viewer node-canvas-webgl

VOLUME /bot/videos

COPY bot.js .

ENTRYPOINT [ "node", "bot.js" ]
