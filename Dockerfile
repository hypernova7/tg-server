FROM alpine:latest as build

ENV CXXFLAGS=""
WORKDIR /telegram-bot-api

RUN apk add --no-cache --update \
  alpine-sdk linux-headers openssl-dev \
  git zlib-dev gperf cmake
COPY telegram-bot-api /telegram-bot-api
RUN mkdir -p build \
  && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. \
  && cmake --build . --target install -j $(nproc) \
  && strip /telegram-bot-api/bin/telegram-bot-api

FROM alpine:latest

ENV TELEGRAM_WORK_DIR="/file" \
    TELEGRAM_TEMP_DIR="/tmp"

RUN apk add --no-cache --update \
  openssl libstdc++ nginx supervisor\
  python3 py3-pip \
  uwsgi-python3 uwsgi-http
COPY --from=build /telegram-bot-api/bin/telegram-bot-api /usr/local/bin/telegram-bot-api
COPY init-server.sh /init-server.sh
COPY home/proxy.py /home/proxy.py
COPY home/requirements.txt /home/requirements.txt
COPY home/envsub /usr/local/bin/envsub
COPY config/uwsgi.yml /etc/uwsgi/uwsgi.yml
COPY config/mime.types /etc/nginx/mime.types
COPY config/nginx.conf.tmpl /etc/nginx/nginx.conf.tmpl
COPY config/supervisord.conf /etc/supervisor/supervisord.conf
RUN addgroup -g 777 -S telegram-bot-api \
  && adduser -S -D -H -u 777 -h ${TELEGRAM_WORK_DIR} -s /sbin/nologin -G telegram-bot-api -g telegram-bot-api telegram-bot-api \
  && mkdir -p ${TELEGRAM_WORK_DIR} ${TELEGRAM_TEMP_DIR} /run/nginx /logs \
  && chown -R telegram-bot-api:telegram-bot-api ${TELEGRAM_WORK_DIR} ${TELEGRAM_TEMP_DIR} \
  && chmod +x /usr/local/bin/envsub /init-server.sh \
  && pip3 install -qr /home/requirements.txt

EXPOSE 8080/tcp
ENTRYPOINT /init-server.sh
