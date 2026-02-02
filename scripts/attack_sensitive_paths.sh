#!/usr/bin/env bash
set -e
TARGET=${1:-http://openresty}
paths=(/.env /wp-admin /phpmyadmin /admin /../../etc/passwd)
for p in "${paths[@]}"; do
  for i in $(seq 1 10); do
    curl -s -o /dev/null "${TARGET}${p}" || true
  done
done
echo "Probed common sensitive paths."
