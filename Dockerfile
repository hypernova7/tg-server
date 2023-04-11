FROM alpine:latest as build

ENV CXXFLAGS="-fuse-ld=mold"
WORKDIR /telegram-bot-api

RUN apk add --no-cache --update \
  alpine-sdk linux-headers openssl-dev \
  git zlib-dev gperf cmake mold
COPY telegram-bot-api /telegram-bot-api
RUN mkdir -p build \
  && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. \
  && cmake --build . --target install -j $(nproc) \
  && strip /telegram-bot-api/bin/telegram-bot-api



FROM alpine:latest

ENV TELEGRAM_WORK_DIR="/file" \
    TELEGRAM_TEMP_DIR="/tmp" \
    MACHINE_USERNAME="telegram-bot-api" \
    MACHINE_GROUPNAME="telegram-bot-api"

RUN apk add --no-cache --update \
  curl \
  libstdc++ \
  nginx \
  openssl \
  python3 \
  py3-pip \
  supervisor \
  uwsgi-python3

COPY --from=build /telegram-bot-api/bin/telegram-bot-api /usr/local/bin/telegram-bot-api
COPY init-server.sh /init-server.sh
COPY home/proxy.py /home/proxy.py
COPY home/requirements.txt /home/requirements.txt
COPY home/envsub /usr/local/bin/envsub
COPY config/uwsgi.ini /etc/uwsgi/uwsgi.ini
COPY config/nginx.conf.tmpl /etc/nginx/nginx.conf.tmpl
COPY config/supervisord.conf /etc/supervisord.conf

RUN addgroup -g 777 -S ${MACHINE_GROUPNAME} \
  && adduser -S -D -H -u 777 -h ${TELEGRAM_WORK_DIR} -s /sbin/nologin -G ${MACHINE_GROUPNAME} -g ${MACHINE_GROUPNAME} ${MACHINE_USERNAME} \
  && mkdir -p ${TELEGRAM_WORK_DIR} ${TELEGRAM_TEMP_DIR} /run/nginx /logs \
  && chown -R ${MACHINE_USERNAME}:${MACHINE_GROUPNAME} ${TELEGRAM_WORK_DIR} ${TELEGRAM_TEMP_DIR} \
  && chmod +x /usr/local/bin/envsub /init-server.sh \
  && pip3 install -qr /home/requirements.txt

EXPOSE 8080/tcp
ENTRYPOINT /init-server.sh
