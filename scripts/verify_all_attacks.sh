#!/bin/bash

echo "========================================"
echo "CROWDSEC IPS DEMO - FINAL VERIFICATION"
echo "Testing all 5 working attacks"
echo "========================================"

# Function to test an attack
test_attack() {
    local attack_name="$1"
    local script_path="$2"
    local expected_scenario="$3"
    
    echo ""
    echo "----------------------------------------"
    echo "Testing: $attack_name"
    echo "----------------------------------------"
    
    # Clean slate
    docker-compose exec crowdsec cscli decisions delete --all > /dev/null 2>&1
    docker-compose exec openresty sh -c "echo '' > /var/log/nginx/access.log"
    sleep 1
    
    # Run attack
    echo "Running attack..."
    docker-compose exec attacker bash "$script_path"
    
    # Wait for detection
    echo "Waiting for CrowdSec detection..."
    sleep 5
    
    # Check if blocked
    echo "Checking if IP is blocked..."
    response=$(docker-compose exec attacker curl -s -o /dev/null -w "%{http_code}" http://openresty)
    
    if [ "$response" = "403" ]; then
        echo "✅ SUCCESS: IP is blocked (403 Forbidden)"
        
        # Show decision
        echo ""
        echo "Decision details:"
        docker-compose exec crowdsec cscli decisions list
        
        # Get alert ID
        alert_id=$(docker-compose exec crowdsec cscli alerts list -o json | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)
        if [ -n "$alert_id" ]; then
            echo ""
            echo "Alert details:"
            docker-compose exec crowdsec cscli alerts inspect "$alert_id"
        fi
        
        return 0
    else
        echo "❌ FAILED: IP not blocked (got $response instead of 403)"
        echo ""
        echo "Checking metrics..."
        docker-compose exec crowdsec cscli metrics show acquisition
        echo ""
        docker-compose exec crowdsec cscli metrics show scenarios | grep -i "$expected_scenario"
        return 1
    fi
}

# Track results
total=5
passed=0

# Test each attack
if test_attack "404 Flood" "/scripts/attack_404_flood.sh" "404"; then
    ((passed++))
fi

if test_attack "Sensitive Files" "/scripts/attack_sensitive_paths.sh" "sensitive"; then
    ((passed++))
fi

if test_attack "POST Flood" "/scripts/attack_post_flood.sh" "post"; then
    ((passed++))
fi

if test_attack "HTTP Method Abuse" "/scripts/attack_method_abuse.sh" "method"; then
    ((passed++))
fi

if test_attack "Scanner Detection v3" "/scripts/attack_scanner_v3.sh" "probing"; then
    ((passed++))
fi

# Final summary
echo ""
echo "========================================"
echo "FINAL RESULTS"
echo "========================================"
echo "Passed: $passed/$total"

if [ $passed -eq $total ]; then
    echo "✅ ALL ATTACKS WORKING - DEMO READY!"
    exit 0
else
    echo "⚠️ Some attacks failed - check logs above"
    exit 1
fi
