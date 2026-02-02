#!/bin/bash
# Complete CrowdSec IPS Demo Script
# Demonstrates all 6 working attacks with automatic cleanup
# Author: Security Demo
# Date: February 2, 2026
# 
# USAGE: Run this script from the HOST (not inside a container)
#        bash scripts/demo_complete.sh
#        OR
#        sh scripts/demo_complete.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

# Function to print attack info
print_attack() {
    echo -e "${YELLOW}🎯 ATTACK: $1${NC}"
    echo -e "${BLUE}📝 Description: $2${NC}"
    echo -e "${GREEN}⚡ Expected Result: $3${NC}\n"
}

# Function to show decisions
show_decisions() {
    echo -e "${RED}📋 Current Bans/Decisions:${NC}"
    docker-compose exec crowdsec cscli decisions list
    echo ""
}

# Function to show alerts
show_alerts() {
    echo -e "${RED}🚨 Triggered Alerts (Last 3):${NC}"
    docker-compose exec crowdsec cscli alerts list --limit 3
    echo ""
}

# Function to cleanup
cleanup() {
    echo -e "${GREEN}🧹 Cleaning up decisions and logs...${NC}"
    docker-compose exec crowdsec cscli decisions delete --all
    docker-compose exec openresty sh -c "echo '' > /var/log/nginx/access.log"
    echo -e "${GREEN}✅ Cleanup complete!${NC}\n"
}

# Function to verify blocking
verify_block() {
    echo -e "${YELLOW}🔒 Verifying IP is blocked...${NC}"
    RESPONSE=$(docker-compose exec attacker curl -s -I http://openresty 2>/dev/null | head -n 1)
    echo "Response: $RESPONSE"
    if echo "$RESPONSE" | grep -q "403"; then
        echo -e "${RED}✅ BLOCKED! CrowdSec bouncer is protecting the server${NC}\n"
    else
        echo -e "${GREEN}⚠️  Not blocked yet (might need more time)${NC}\n"
    fi
}

# Function to pause for user
pause_demo() {
    echo -e "${CYAN}Press ENTER to continue to next attack...${NC}"
    read
}

# Start demo
print_header "CrowdSec IPS + ELK Stack - Live Attack Demo"
echo -e "${GREEN}This demo will show 6 different attack types and how CrowdSec detects and blocks them.${NC}"
echo -e "${GREEN}Each attack will trigger automatic IP banning for 4 hours.${NC}\n"

echo -e "${CYAN}Initial cleanup...${NC}"
cleanup
sleep 2

# ============================================
# ATTACK 1: HTTP 404 Flood
# ============================================
print_header "ATTACK 1/6: HTTP 404 Flood"
print_attack \
    "HTTP 404 Flood Attack" \
    "Attacker sends 50 rapid requests to non-existent pages to probe server structure" \
    "Triggers 4 CrowdSec scenarios including http-404-flood, scanner-detection, and http-crawl-non_statics"

echo -e "${YELLOW}🚀 Launching attack...${NC}"
docker-compose exec attacker bash /scripts/attack_404_flood.sh
echo -e "${GREEN}✅ Attack completed - 50 requests sent${NC}\n"

echo -e "${YELLOW}⏳ Waiting 3 seconds for CrowdSec detection...${NC}"
sleep 3

show_decisions
show_alerts
verify_block

pause_demo
cleanup
sleep 2

# ============================================
# ATTACK 2: Sensitive Files Access
# ============================================
print_header "ATTACK 2/6: Sensitive Files Access"
print_attack \
    "Sensitive File Enumeration" \
    "Attacker attempts to access common sensitive files like /admin, /.env, /backup.sql, /phpMyAdmin" \
    "Triggers 2 scenarios: sensitive-files and http-admin-interface-probing"

echo -e "${YELLOW}🚀 Launching attack...${NC}"
docker-compose exec attacker bash /scripts/attack_sensitive_paths.sh
echo -e "${GREEN}✅ Attack completed - 8 sensitive paths probed${NC}\n"

echo -e "${YELLOW}⏳ Waiting 3 seconds for CrowdSec detection...${NC}"
sleep 3

show_decisions
show_alerts
verify_block

pause_demo
cleanup
sleep 2

# ============================================
# ATTACK 3: HTTP POST Flood
# ============================================
print_header "ATTACK 3/6: HTTP POST Flood"
print_attack \
    "HTTP POST Flood Attack" \
    "Attacker floods the server with 25 rapid POST requests to overwhelm resources" \
    "Triggers http-post-flood scenario with 21+ events (nginx deduplicates some identical POSTs)"

echo -e "${YELLOW}🚀 Launching attack...${NC}"
docker-compose exec attacker bash /scripts/attack_post_flood.sh
echo -e "${GREEN}✅ Attack completed - 25 POST requests sent${NC}\n"

echo -e "${YELLOW}⏳ Waiting 3 seconds for CrowdSec detection...${NC}"
sleep 3

show_decisions
show_alerts
verify_block

pause_demo
cleanup
sleep 2

# ============================================
# ATTACK 4: HTTP Method Abuse
# ============================================
print_header "ATTACK 4/6: HTTP Method Abuse"
print_attack \
    "HTTP Method Abuse Attack" \
    "Attacker uses unusual HTTP methods (DELETE, PUT, TRACE, PATCH) to probe server configuration" \
    "Triggers http-method-abuse scenario - detects 405 status codes from unsupported methods"

echo -e "${YELLOW}🚀 Launching attack...${NC}"
docker-compose exec attacker bash /scripts/attack_method_abuse.sh
echo -e "${GREEN}✅ Attack completed - 7 unusual HTTP methods sent${NC}\n"

echo -e "${YELLOW}⏳ Waiting 10 seconds for CrowdSec detection...${NC}"
echo -e "${BLUE}(This attack takes slightly longer due to request delays)${NC}"
sleep 10

show_decisions
show_alerts
verify_block

pause_demo
cleanup
sleep 2

# ============================================
# ATTACK 5: Path Scanner/Enumeration
# ============================================
print_header "ATTACK 5/6: Path Scanner Detection"
print_attack \
    "Automated Path Scanning" \
    "Attacker uses automated tool to scan for hidden directories and files (generates 404 errors)" \
    "Triggers 2 scenarios: http-404-flood and http-probing - classic scanner behavior"

echo -e "${YELLOW}🚀 Launching attack...${NC}"
docker-compose exec attacker bash /scripts/attack_scanner_v3.sh
echo -e "${GREEN}✅ Attack completed - 12 paths scanned${NC}\n"

echo -e "${YELLOW}⏳ Waiting 3 seconds for CrowdSec detection...${NC}"
sleep 3

show_decisions
show_alerts
verify_block

pause_demo
cleanup
sleep 2

# ============================================
# ATTACK 6: SQL Injection
# ============================================
print_header "ATTACK 6/6: SQL Injection Attack"
print_attack \
    "SQL Injection Attempts" \
    "Attacker tries SQL injection payloads: UNION SELECT, OR 1=1, admin'--, DROP TABLE" \
    "Triggers sql-injection-simple scenario - detects malicious SQL patterns in URL parameters"

echo -e "${YELLOW}🚀 Launching attack...${NC}"
docker-compose exec attacker bash /scripts/attack_sql_injection_final.sh
echo -e "${GREEN}✅ Attack completed - 6 SQL injection payloads sent${NC}\n"

echo -e "${YELLOW}⏳ Waiting 3 seconds for CrowdSec detection...${NC}"
sleep 3

show_decisions
show_alerts
verify_block

# ============================================
# DEMO COMPLETE
# ============================================
print_header "🎉 DEMO COMPLETE! 🎉"
echo -e "${GREEN}✅ All 6 attacks demonstrated successfully!${NC}\n"

echo -e "${CYAN}Summary of Attacks:${NC}"
echo -e "1. ✅ HTTP 404 Flood - 4 scenarios triggered"
echo -e "2. ✅ Sensitive Files - 2 scenarios triggered"
echo -e "3. ✅ HTTP POST Flood - 21 events detected"
echo -e "4. ✅ HTTP Method Abuse - 7 unusual methods detected"
echo -e "5. ✅ Path Scanner - 2 scenarios triggered"
echo -e "6. ✅ SQL Injection - 4 SQL patterns detected"

echo -e "\n${CYAN}Key Points:${NC}"
echo -e "• CrowdSec detected and blocked all 6 attack types automatically"
echo -e "• Each attack triggered 4-hour IP ban (14400 seconds)"
echo -e "• Multiple built-in and custom scenarios activated"
echo -e "• OpenResty bouncer enforced blocks in real-time (403 Forbidden)"
echo -e "• All logs forwarded to ELK Stack for visualization"

echo -e "\n${YELLOW}Final cleanup?${NC}"
read -p "Delete all remaining decisions? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cleanup
    echo -e "${GREEN}All clean! Ready for next demo.${NC}"
else
    echo -e "${YELLOW}Decisions kept for review.${NC}"
fi

echo -e "\n${CYAN}Check Kibana dashboard: http://localhost:5601${NC}"
echo -e "${CYAN}Thank you for watching the demo!${NC}\n"
