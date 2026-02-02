#!/usr/bin/env bash
set -e
TARGET=${1:-http://openresty}
for i in $(seq 1 50); do
  curl -s -o /dev/null "${TARGET}/nope-$i" || true
done
echo "Sent 50x 404 requests."
