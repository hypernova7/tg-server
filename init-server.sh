#!/usr/bin/env sh
set -e

envsub /etc/nginx/nginx.conf.tmpl > /etc/nginx/nginx.conf
supervisord -c /etc/supervisor/supervisord.conf
