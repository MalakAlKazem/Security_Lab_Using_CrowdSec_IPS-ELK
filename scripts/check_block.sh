#!/usr/bin/env bash
set -e
TARGET=${1:-http://openresty}
code=$(curl -s -o /dev/null -w "%{http_code}" "${TARGET}/")
echo "HTTP status: $code (403 means blocked)"
