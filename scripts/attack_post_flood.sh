#!/usr/bin/env bash
set -e
TARGET=${1:-http://openresty}

echo "Starting POST flood attack..."

# Send rapid POST requests
for i in $(seq 1 50); do
  curl -s -o /dev/null -X POST "${TARGET}/api/data" \
    -d "data=test_${i}" \
    -H "Content-Type: application/x-www-form-urlencoded" || true
done

echo "Sent 50 POST requests in rapid succession."
