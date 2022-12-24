#!/usr/bin/env sh
set -e

# You can set the swap size if needed, just set the SWAP_SIZE environment variable, by default is 0
# (You can even specify size in bytes)
# Example: SWAP_SIZE=200M or SWAP_SIZE=4G or SWAP_SIZE=8589934592 (8589934592 = 8G)
# You can use this prefixes:
# - k or K = Kilobytes
# - m o M = Megabytes
# - g or G = Gigabytes
SWAP_SIZE=${SWAP_SIZE:-0} # Set default value to 0 if SWAP_SIZE environment variable not exists

# Convert human readable size to bytes
# Source: https://stackoverflow.com/a/26621833
size_to_bytes() {
  echo $1 | awk \
    '/[0-9]$/{print $1;next};
    /[gG]$/{printf "%u", $1*(1024*1024*1024);next};
    /[mM]$/{printf "%u", $1*(1024*1024);next};
    /[kK]$/{printf "%u", $1*1024;next}'
}

SWAP_SIZE_IN_BYTES=`size_to_bytes $SWAP_SIZE`

# Only setup swap if SWAP_SIZE_IN_BYTES IS greater than 0
if [ $SWAP_SIZE_IN_BYTES -ne 0 ]; then
  # Assign size to swap
  fallocate -l $SWAP_SIZE _swapfile
  # Setup swap
  mkswap _swapfile
  # Enable swap
  swapon _swapfile
fi

# Replace environment variables
envsub /etc/nginx/nginx.conf.tmpl > /etc/nginx/nginx.conf
# Start services
supervisord -c /etc/supervisor/supervisord.conf
