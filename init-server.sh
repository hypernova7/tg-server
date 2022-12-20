#!/usr/bin/env sh
set -e

# Increase swap size to %20 of available space (set the SWAP environment variable)
# (this is only required on fly.io)
if [[ ! -z "$SWAP" ]]; then
  fallocate -l $(($(stat -f -c "(%a*%s/10)*2" .))) _swapfile
  mkswap _swapfile
  swapon _swapfile
fi

envsub /etc/nginx/nginx.conf.tmpl > /etc/nginx/nginx.conf
supervisord -c /etc/supervisor/supervisord.conf
