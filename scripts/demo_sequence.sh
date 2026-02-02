#!/usr/bin/env bash
set -e

TARGET=${1:-http://openresty}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔════════════════════════════════════════════════╗"
echo "║   CrowdSec IPS + ELK Stack - Demo Sequence    ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
echo "Target: ${TARGET}"
echo ""

# Function to show step header
show_step() {
  echo ""
  echo "┌────────────────────────────────────────────────┐"
  echo "│ $1"
  echo "└────────────────────────────────────────────────┘"
}

# Function to pause
pause() {
  echo ""
  read -p "Press Enter to continue to next attack..."
  echo ""
}

show_step "STEP 1: Verify initial access"
echo "Testing normal access to the target..."
bash "${SCRIPT_DIR}/check_block.sh" "${TARGET}"
pause

show_step "STEP 2: 404 Flood Attack (50 requests)"
echo "Simulating aggressive scanning with 404 errors..."
bash "${SCRIPT_DIR}/attack_404_flood.sh" "${TARGET}"
echo "✓ Attack completed"
pause

show_step "STEP 3: Sensitive Files Probing"
echo "Attempting to access sensitive paths (.env, wp-admin, etc.)..."
bash "${SCRIPT_DIR}/attack_sensitive_paths.sh" "${TARGET}"
echo "✓ Attack completed"
pause

show_step "STEP 4: Login Brute Force"
echo "Attempting to brute force login credentials..."
bash "${SCRIPT_DIR}/attack_login_bruteforce.sh" "${TARGET}"
echo "✓ Attack completed"
pause

show_step "STEP 5: POST Flood Attack"
echo "Flooding with POST requests..."
bash "${SCRIPT_DIR}/attack_post_flood.sh" "${TARGET}"
echo "✓ Attack completed"
pause

show_step "STEP 6: HTTP Method Abuse"
echo "Using unusual HTTP methods (DELETE, PUT, TRACE, etc.)..."
bash "${SCRIPT_DIR}/attack_method_abuse.sh" "${TARGET}"
echo "✓ Attack completed"
pause

show_step "STEP 7: Web Scanner Simulation"
echo "Enumerating multiple paths like a web scanner..."
bash "${SCRIPT_DIR}/attack_scanner.sh" "${TARGET}"
echo "✓ Attack completed"
pause

show_step "STEP 8: Check if blocked"
echo "Verifying if CrowdSec has blocked our IP..."
bash "${SCRIPT_DIR}/check_block.sh" "${TARGET}"

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║            Demo Sequence Complete!             ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Check CrowdSec decisions: cscli decisions list"
echo "  2. View Kibana dashboards at http://localhost:5601"
echo "  3. Review logs in Elasticsearch"
echo ""
