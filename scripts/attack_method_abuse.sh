#!/usr/bin/env bash
set -e
TARGET=${1:-http://openresty}

echo "Starting HTTP method abuse attack..."

# Try various unusual/dangerous HTTP methods
methods=("DELETE" "PUT" "TRACE" "OPTIONS" "PATCH" "CONNECT")

count=0
for method in "${methods[@]}"; do
  for i in $(seq 1 10); do
    curl -s -o /dev/null -X "${method}" "${TARGET}/?req=${i}" || true
    ((count++))
    sleep 0.05  # Small delay to ensure logging
  done
done

echo "Sent ${count} requests with various HTTP methods."
