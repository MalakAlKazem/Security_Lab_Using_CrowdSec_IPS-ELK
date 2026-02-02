#!/usr/bin/env bash
set -e

TARGET=${1:-http://openresty}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo "Running ALL attack scenarios against: ${TARGET}"
echo "========================================="
echo ""

echo "[1/8] 404 Flood Attack..."
bash "${SCRIPT_DIR}/attack_404_flood.sh" "${TARGET}"
sleep 2

echo ""
echo "[2/8] Sensitive Paths Probing..."
bash "${SCRIPT_DIR}/attack_sensitive_paths.sh" "${TARGET}"
sleep 2

echo ""
echo "[3/8] Login Brute Force..."
bash "${SCRIPT_DIR}/attack_login_bruteforce.sh" "${TARGET}"
sleep 2

echo ""
echo "[4/8] POST Flood Attack..."
bash "${SCRIPT_DIR}/attack_post_flood.sh" "${TARGET}"
sleep 2

echo ""
echo "[5/8] HTTP Method Abuse..."
bash "${SCRIPT_DIR}/attack_method_abuse.sh" "${TARGET}"
sleep 2

echo ""
echo "[6/8] Scanner/Enumeration Attack..."
bash "${SCRIPT_DIR}/attack_scanner.sh" "${TARGET}"
sleep 2

echo ""
echo "[7/8] SQL Injection Attempts..."
bash "${SCRIPT_DIR}/attack_sql_injection.sh" "${TARGET}"
sleep 2

echo ""
echo "[8/8] XSS Injection Attempts..."
bash "${SCRIPT_DIR}/attack_xss.sh" "${TARGET}"

echo ""
echo "========================================="
echo "All attacks completed!"
echo "========================================="
echo ""
echo "Check if you're blocked:"
bash "${SCRIPT_DIR}/check_block.sh" "${TARGET}"
