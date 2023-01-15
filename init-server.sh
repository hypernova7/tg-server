#!/usr/bin/env sh
set -e


## ------------------------------------------------ SWAP FILE ------------------------------------------------ ##
# You can set the swap size if needed, just set the SWAP_SIZE environment variable. (default 0)
# Example: SWAP_SIZE=200M or SWAP_SIZE=4G or SWAP_SIZE=8589934592 (8589934592 = 8G)
# Use these prefixes or in bytes:
# - k or K = Kilobytes
# - m o M = Megabytes
# - g or G = Gigabytes
SWAP_SIZE=${SWAP_SIZE:-0}                                                     # Default value is 0 if SWAP_SIZE ENV not set

# Convert human readable size to bytes                                        (Source: https://stackoverflow.com/a/26621833)
size_to_bytes() {
  echo $1 | awk \
    '/^-/{print "NEGATIVE_VALUE";next};
    /[0-9]$/{print $1;next};
    /[gG]$/{printf "%u", $1*(1024*1024*1024);next};
    /[mM]$/{printf "%u", $1*(1024*1024);next};
    /[kK]$/{printf "%u", $1*1024;next}'
}

SWAP_SIZE_IN_BYTES=`size_to_bytes $SWAP_SIZE`

# Check if SWAP_SIZE has negative values, if so then set SWAP_SIZE to 0
if [ "$SWAP_SIZE_IN_BYTES" = "NEGATIVE_VALUE" ]; then
  echo "SWAP_SIZE_ERROR: Negative values are not allowed."
  SWAP_SIZE_IN_BYTES=0
fi

# Setup swap file if SWAP_SIZE_IN_BYTES is greater than 0
if [ $SWAP_SIZE_IN_BYTES -ne 0 ]; then
  fallocate -l $SWAP_SIZE _swapfile                                             # Assign size to swap
  mkswap _swapfile                                                              # Setup swap
  swapon _swapfile                                                              # Enable swap
fi


## ------------------------------------------------ PROGRAM ------------------------------------------------ ##
envsub /etc/nginx/nginx.conf.tmpl > /etc/nginx/nginx.conf                       # Replace environment variables
supervisord -c /etc/supervisord.conf                                            # Start services
