#!/usr/bin/env bash
set -e
TARGET=${1:-http://openresty}

echo "Starting SQL injection attack (FINAL - unique GETs)..."

# Make each request truly unique by varying the path AND query string
# This ensures nginx doesn't deduplicate them

curl -s "http://openresty/search1?q='%20OR%20'1'='1&x=1" > /dev/null || true
sleep 0.3

curl -s "http://openresty/search2?user=admin'--&y=2" > /dev/null || true
sleep 0.3

curl -s "http://openresty/api?id='%20OR%201=1--&z=3" > /dev/null || true
sleep 0.3

curl -s "http://openresty/products?pid=1%20UNION%20SELECT%20null&a=4" > /dev/null || true
sleep 0.3

curl -s "http://openresty/users?uid='%20DROP%20TABLE%20users--&b=5" > /dev/null || true
sleep 0.3

curl -s "http://openresty/login?pass=1'%20AND%20'1'='1&c=6" > /dev/null || true
sleep 0.3

echo "Sent 6 SQL injection attempts with unique paths."
