FROM alpine:3.15 as build

ENV CXXFLAGS=""
WORKDIR /telegram-bot-api

RUN apk add --no-cache --update alpine-sdk linux-headers git zlib-dev openssl-dev gperf cmake
COPY telegram-bot-api /telegram-bot-api
RUN mkdir -p build \
  && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. \
  && cmake --build . --target install -j $(nproc) \
  && strip /telegram-bot-api/bin/telegram-bot-api

FROM alpine:3.15

ENV TELEGRAM_WORK_DIR="/file" \
    TELEGRAM_TEMP_DIR="/tmp"

RUN apk add --no-cache --update openssl libstdc++ nginx python3 py3-pip
COPY proxy.py /proxy.py
COPY requirements.txt /requirements.txt
COPY nginx/mime.types /etc/nginx/conf.d/mime.types
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /telegram-bot-api/bin/telegram-bot-api /usr/local/bin/telegram-bot-api
RUN addgroup -g 777 -S telegram-bot-api \
  && adduser -S -D -H -u 777 -h ${TELEGRAM_WORK_DIR} -s /sbin/nologin -G telegram-bot-api -g telegram-bot-api telegram-bot-api \
  && mkdir -p ${TELEGRAM_WORK_DIR} ${TELEGRAM_TEMP_DIR} \
  && chown telegram-bot-api:telegram-bot-api ${TELEGRAM_WORK_DIR} ${TELEGRAM_TEMP_DIR} \
  && mkdir -p /telegram-bot-api/logs \
  && mkdir -p /run/nginx
RUN pip3 install -r /requirements.txt

CMD (telegram-bot-api -p 8081 --api-id=$TELEGRAM_API_ID --api-hash=$TELEGRAM_API_HASH --dir=/file --temp-dir=/tmp $EXTRA_ARGS) & \
  (gunicorn -w 8 --worker-connections 65535 -b 127.0.0.1:8282 proxy:app) & \
  sed -i "s/__PORT__/$PORT/g" /etc/nginx/conf.d/default.conf \
  && nginx -p /telegram-bot-api -c /etc/nginx/conf.d/default.conf
