#!/usr/bin/env bash
set -e
TARGET=${1:-http://openresty}

echo "Starting scanner/enumeration attack with 404s (v3)..."

# Hit backend directly through proxy to generate real 404s
# These will all be logged because they're real requests
for i in {1..12}; do
  curl -s -o /dev/null "${TARGET}/nonexistent${i}?scan=${i}" || true
  sleep 0.15
done

echo "Scanned 12 nonexistent paths - should trigger scanner detection."
