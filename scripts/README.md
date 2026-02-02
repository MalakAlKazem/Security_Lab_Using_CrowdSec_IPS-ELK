# Attack Scripts for CrowdSec Demo

This directory contains various attack simulation scripts to demonstrate CrowdSec's detection and blocking capabilities.

## Prerequisites

Run these scripts from inside the **attacker** container:

```bash
docker-compose exec attacker bash
cd /scripts
```

## Available Attack Scripts

### Individual Attack Scripts

1. **attack_404_flood.sh** - Triggers the 404 flood scenario
   ```bash
   bash attack_404_flood.sh [TARGET_URL]
   ```
   - Sends 50 requests to non-existent pages
   - Triggers: `custom-http-404-flood`

2. **attack_sensitive_paths.sh** - Probes for sensitive files
   ```bash
   bash attack_sensitive_paths.sh [TARGET_URL]
   ```
   - Attempts to access `.env`, `/wp-admin`, `/phpmyadmin`, etc.
   - Triggers: `custom-sensitive-files`

3. **attack_login_bruteforce.sh** - Simulates credential brute forcing
   ```bash
   bash attack_login_bruteforce.sh [TARGET_URL]
   ```
   - Tries multiple username/password combinations
   - Triggers: `custom-login-bruteforce`

4. **attack_post_flood.sh** - Floods with POST requests
   ```bash
   bash attack_post_flood.sh [TARGET_URL]
   ```
   - Sends 50 rapid POST requests
   - Triggers: `custom-http-post-flood`

5. **attack_method_abuse.sh** - Uses unusual HTTP methods
   ```bash
   bash attack_method_abuse.sh [TARGET_URL]
   ```
   - Sends requests with DELETE, PUT, TRACE, OPTIONS, etc.
   - Triggers: `custom-http-method-abuse`

6. **attack_scanner.sh** - Simulates web scanner behavior
   ```bash
   bash attack_scanner.sh [TARGET_URL]
   ```
   - Enumerates 30+ different paths rapidly
   - Triggers: `custom-scanner-detection`

7. **attack_sql_injection.sh** - SQL injection attempts
   ```bash
   bash attack_sql_injection.sh [TARGET_URL]
   ```
   - Tries common SQL injection payloads
   - May trigger multiple scenarios

8. **attack_xss.sh** - XSS injection attempts
   ```bash
   bash attack_xss.sh [TARGET_URL]
   ```
   - Tries common XSS payloads
   - May trigger HTTP abuse scenarios

### Combo Scripts

9. **attack_all.sh** - Runs all attacks sequentially
   ```bash
   bash attack_all.sh [TARGET_URL]
   ```
   - Executes all 8 attack types in order
   - Includes 2-second pauses between attacks
   - Shows blocking status at the end

10. **demo_sequence.sh** - Interactive demo with explanations
    ```bash
    bash demo_sequence.sh [TARGET_URL]
    ```
    - Runs attacks with pauses for explanation
    - Perfect for live demonstrations
    - Shows step-by-step progress

### Utility Scripts

11. **check_block.sh** - Check if IP is blocked
    ```bash
    bash check_block.sh [TARGET_URL]
    ```
    - Returns HTTP status code
    - 403 = blocked by CrowdSec
    - 200 = still allowed

## Usage Examples

### Quick Demo (from attacker container)

```bash
# Run from inside the attacker container
cd /scripts

# Make all scripts executable
chmod +x *.sh

# Run a single attack
bash attack_404_flood.sh

# Run all attacks automatically
bash attack_all.sh

# Run interactive demo
bash demo_sequence.sh
```

### Default Target

All scripts default to `http://openresty` (the OpenResty bouncer service). You can override with:

```bash
bash attack_404_flood.sh http://openresty
```

## Monitoring Results

### Check CrowdSec Decisions

```bash
# From host or crowdsec container
docker-compose exec crowdsec cscli decisions list

# See metrics
docker-compose exec crowdsec cscli metrics
```

### View in Kibana

1. Open http://localhost:5601
2. Go to Discover or your custom dashboards
3. Filter for attack patterns

### Clear Bans (for testing)

```bash
# Remove all decisions
docker-compose exec crowdsec cscli decisions delete --all

# Or remove specific IP
docker-compose exec crowdsec cscli decisions delete --ip <IP_ADDRESS>
```

## Scenarios Triggered

| Script | CrowdSec Scenario |
|--------|-------------------|
| attack_404_flood.sh | custom-http-404-flood |
| attack_sensitive_paths.sh | custom-sensitive-files |
| attack_login_bruteforce.sh | custom-login-bruteforce |
| attack_post_flood.sh | custom-http-post-flood |
| attack_method_abuse.sh | custom-http-method-abuse |
| attack_scanner.sh | custom-scanner-detection |

## Expected Behavior

1. **First few attacks**: Requests go through (200 OK)
2. **After threshold**: CrowdSec detects pattern and bans IP
3. **Subsequent requests**: Blocked by bouncer (403 Forbidden)
4. **Ban duration**: Default 4 hours (configurable in scenarios)

## Troubleshooting

### Scripts not found

Make sure the `/scripts` directory is mounted in docker-compose.yml:

```yaml
attacker:
  volumes:
    - ./scripts:/scripts:ro
```

### Permission denied

Make scripts executable:

```bash
chmod +x /scripts/*.sh
```

### Not getting blocked

- Check CrowdSec is running: `docker-compose ps crowdsec`
- Verify scenarios are loaded: `docker-compose exec crowdsec cscli scenarios list`
- Check logs: `docker-compose logs crowdsec`
- Ensure whitelist isn't blocking detection

## Demo Tips

1. **Reset between demos**: Clear decisions with `cscli decisions delete --all`
2. **Watch logs live**: `docker-compose logs -f crowdsec`
3. **Show Kibana first**: Have dashboards ready before running attacks
4. **Explain each step**: Use `demo_sequence.sh` for paced demonstrations
5. **Verify blocking**: Always end with `check_block.sh` to show the ban

## Notes

- All attacks are **safe simulations** for testing IPS behavior
- No actual exploits are included
- Designed to trigger CrowdSec scenarios only
- Some attacks may take 30-60 seconds to accumulate enough events for banning
