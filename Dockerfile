FROM alpine:latest AS build

ENV CXXFLAGS="-fuse-ld=mold"
WORKDIR /telegram-bot-api

RUN apk add --no-cache --update alpine-sdk linux-headers openssl-dev git zlib-dev gperf cmake mold

COPY telegram-bot-api /telegram-bot-api
RUN mkdir -p build \
  && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. \
  && cmake --build . --target install -j $(nproc) \
  && strip /telegram-bot-api/bin/telegram-bot-api

FROM oven/bun:alpine

ENV TELEGRAM_WORK_DIR="/tmp/file" \
    TELEGRAM_TEMP_DIR="/tmp" \
    MACHINE_USERNAME="telegram-bot-api" \
    MACHINE_GROUPNAME="telegram-bot-api" \
    EXTRA_ARGS="--local"

RUN apk add --no-cache --update curl caddy openssl supervisor

COPY --from=build /telegram-bot-api/bin/telegram-bot-api /usr/bin/telegram-bot-api
COPY config/supervisord.conf /etc/supervisord.conf
COPY config/Caddyfile /etc/Caddyfile
COPY home/server.ts /home/server.ts
COPY package.json /package.json
COPY tsconfig.json /tsconfig.json
COPY bun.lock /bun.lock

RUN addgroup -g 777 -S ${MACHINE_GROUPNAME} \
  && adduser -S -D -H -u 777 -h ${TELEGRAM_WORK_DIR} -s /sbin/nologin -G ${MACHINE_GROUPNAME} -g ${MACHINE_GROUPNAME} ${MACHINE_USERNAME} \
  && mkdir -p ${TELEGRAM_TEMP_DIR} ${TELEGRAM_WORK_DIR} \
  && chown -R ${MACHINE_USERNAME}:${MACHINE_GROUPNAME} ${TELEGRAM_WORK_DIR} ${TELEGRAM_TEMP_DIR} \
  && bun install --production

EXPOSE 8080/tcp
ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
