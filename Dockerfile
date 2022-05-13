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

RUN apk add --no-cache --update openssl libstdc++ nginx python3 py3-pip uwsgi-python3 uwsgi-http supervisor
COPY proxy.py /proxy.py
COPY envsub /usr/local/bin/envsub
COPY requirements.txt /requirements.txt
COPY config/uwsgi.yml /etc/uwsgi/uwsgi.yml
COPY config/mime.types /etc/nginx/mime.types
COPY config/nginx.conf.tmpl /etc/nginx/nginx.conf.tmpl
COPY config/supervisord.conf /etc/supervisor/supervisord.conf
COPY --from=build /telegram-bot-api/bin/telegram-bot-api /usr/local/bin/telegram-bot-api
RUN addgroup -g 777 -S telegram-bot-api \
  && adduser -S -D -H -u 777 -h ${TELEGRAM_WORK_DIR} -s /sbin/nologin -G telegram-bot-api -g telegram-bot-api telegram-bot-api \
  && mkdir -p ${TELEGRAM_WORK_DIR} ${TELEGRAM_TEMP_DIR} \
  && chown telegram-bot-api:telegram-bot-api ${TELEGRAM_WORK_DIR} ${TELEGRAM_TEMP_DIR} \
  && mkdir -p /telegram-bot-api/logs \
  && mkdir -p /run/nginx
RUN chmod +x /usr/local/bin/envsub \
  && pip3 install -r /requirements.txt

CMD envsub /etc/nginx/nginx.conf.tmpl > /etc/nginx/nginx.conf \
  && supervisord -c /etc/supervisor/supervisord.conf