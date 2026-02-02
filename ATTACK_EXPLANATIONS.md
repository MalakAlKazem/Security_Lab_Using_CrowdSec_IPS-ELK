# Attack Scripts - Presentation Guide

Complete explanations for each attack scenario in your CrowdSec + ELK demo.

---

## 1. 404 Flood Attack (`attack_404_flood.sh`)

### What It Does
Sends 50 rapid requests to non-existent pages (e.g., `/nope-1`, `/nope-2`, etc.)

### Real-World Scenario
- **Automated scanners** looking for hidden directories
- **Reconnaissance phase** of an attack - testing for vulnerabilities
- **Directory bruteforcing** tools like DirBuster or GoBuster

### How It Works
```bash
for i in $(seq 1 50); do
  curl "${TARGET}/nope-$i"
done
```
Sends 50 consecutive GET requests to URLs that don't exist, generating 404 errors.

### What CrowdSec Detects
- **Scenario Triggered**: `custom/http-404-flood` + `crowdsecurity/http-crawl-non_statics`
- **Detection Logic**: More than 10 404 errors within 10 seconds from same IP
- **Why It Matters**: Legitimate users don't generate mass 404s - this is automated tool behavior

### Demo Talking Points
- "Notice how a normal user might get 1-2 404s by mistyping a URL"
- "But 50 rapid 404s? That's clearly an automated scanner"
- "CrowdSec recognizes this pattern and blocks the attacker"

---

## 2. Sensitive Files Probing (`attack_sensitive_paths.sh`)

### What It Does
Attempts to access 5 sensitive paths, each 10 times:
- `/.env` - Environment variables (credentials, API keys)
- `/wp-admin` - WordPress admin panel
- `/phpmyadmin` - Database admin interface
- `/admin` - Generic admin panel
- `/../../etc/passwd` - Path traversal attempt

### Real-World Scenario
- **Information gathering** - looking for leaked configuration files
- **Known vulnerability exploitation** - targeting common CMS installations
- **Path traversal attacks** - trying to access system files
- **Automated vulnerability scanners** (Nikto, Acunetix, etc.)

### How It Works
```bash
paths=(/.env /wp-admin /phpmyadmin /admin /../../etc/passwd)
for p in "${paths[@]}"; do
  for i in $(seq 1 10); do
    curl "${TARGET}${p}"
  done
done
```

### What CrowdSec Detects
- **Scenarios Triggered**: 
  - `custom/sensitive-files`
  - `crowdsecurity/http-admin-interface-probing`
  - `crowdsecurity/http-path-traversal-probing`
- **Detection Logic**: 3+ different sensitive paths accessed within 60 seconds
- **Why It Matters**: These files contain credentials and sensitive data

### Demo Talking Points
- "Attackers look for configuration files that developers accidentally expose"
- "The .env file often contains database passwords and API keys"
- "Path traversal (../../etc/passwd) tries to escape the web root"
- "Multiple admin panel checks suggest reconnaissance for an attack"

---

## 3. Login Brute Force (`attack_login_bruteforce.sh`)

### What It Does
Tries 25 username/password combinations (5 users × 5 passwords):
- Usernames: admin, root, user, test, administrator
- Passwords: password, admin, 123456, letmein, admin123

### Real-World Scenario
- **Credential stuffing** - trying leaked passwords
- **Brute force attacks** - systematically trying combinations
- **Automated bots** targeting weak passwords
- Real-world example: WordPress login attacks (millions daily)

### How It Works
```bash
usernames=("admin" "root" "user" "test" "administrator")
passwords=("password" "admin" "123456" "letmein" "admin123")
for user in "${usernames[@]}"; do
  for pass in "${passwords[@]}"; do
    curl -X POST "${TARGET}/login" -d "username=${user}&password=${pass}"
  done
done
```

### What CrowdSec Detects
- **Scenario Triggered**: `custom/login-bruteforce` + `crowdsecurity/http-generic-bf`
- **Detection Logic**: 5+ failed login attempts within 2 minutes
- **Why It Matters**: Prevents account takeovers and data breaches

### Demo Talking Points
- "These are the most common passwords used in attacks"
- "Attackers use lists of millions of username/password combinations"
- "Even with rate limiting, without an IPS, they can try thousands per hour"
- "CrowdSec blocks the IP after detecting the pattern"

---

## 4. POST Flood Attack (`attack_post_flood.sh`)

### What It Does
Sends 50 rapid POST requests to `/api/data` with dummy payloads

### Real-World Scenario
- **API abuse** - overwhelming backend resources
- **DoS (Denial of Service)** - making the service unavailable
- **Resource exhaustion** - filling up databases/logs
- **Testing for input validation issues**

### How It Works
```bash
for i in $(seq 1 50); do
  curl -X POST "${TARGET}/api/data" -d "data=test_${i}"
done
```

### What CrowdSec Detects
- **Scenario Triggered**: `custom/http-post-flood`
- **Detection Logic**: 20+ POST requests to same endpoint within 30 seconds
- **Why It Matters**: POST requests are more expensive (write operations)

### Demo Talking Points
- "POST requests modify data - they're more resource-intensive than GET"
- "Legitimate users don't submit 50 forms in 10 seconds"
- "This could fill up your database or crash your application"
- "CrowdSec distinguishes between normal API usage and abuse"

---

## 5. HTTP Method Abuse (`attack_method_abuse.sh`)

### What It Does
Sends 60 requests using unusual HTTP methods (10 each):
- DELETE - Should remove resources
- PUT - Should update resources
- TRACE - Debugging method (security risk)
- OPTIONS - Discovers allowed methods
- PATCH - Partial updates
- CONNECT - Tunneling (proxy abuse)

### Real-World Scenario
- **HTTP verb tampering** - bypassing security controls
- **TRACE method vulnerability** - XSS/credential theft
- **API testing** - looking for improperly secured endpoints
- **Proxy abuse** - using CONNECT for tunneling

### How It Works
```bash
methods=("DELETE" "PUT" "TRACE" "OPTIONS" "PATCH" "CONNECT")
for method in "${methods[@]}"; do
  for i in $(seq 1 10); do
    curl -X "${method}" "${TARGET}/"
  done
done
```

### What CrowdSec Detects
- **Scenario Triggered**: `custom/http-method-abuse`
- **Detection Logic**: 5+ requests with non-standard methods within 60 seconds
- **Why It Matters**: Legitimate browsers primarily use GET/POST

### Demo Talking Points
- "Normal web browsing uses GET and POST"
- "DELETE, PUT, TRACE are used by attackers to find vulnerabilities"
- "TRACE method can expose authentication tokens"
- "This pattern indicates someone probing your API security"

---

## 6. Web Scanner Detection (`attack_scanner.sh`)

### What It Does
Rapidly accesses 30+ different paths in succession, mimicking automated scanners:
- Admin panels: `/admin`, `/wp-admin`, `/phpmyadmin`
- Config files: `/.env`, `/.git/config`, `/config.php`
- Backup files: `/backup.zip`, `/database.sql`
- Debug endpoints: `/debug`, `/console`, `/swagger`
- Info disclosure: `/phpinfo.php`, `/server-status`

### Real-World Scenario
- **Automated vulnerability scanners** (Nikto, Nessus, OpenVAS)
- **Web crawlers** looking for exploitable endpoints
- **Reconnaissance before targeted attack**
- **Bug bounty hunters** (unauthorized scanning)

### How It Works
```bash
paths=("/admin" "/wp-admin" "/.env" "/.git/config" "/backup.zip" ...)
for path in "${paths[@]}"; do
  curl "${TARGET}${path}"
done
```

### What CrowdSec Detects
- **Scenarios Triggered**: 
  - `custom/scanner-detection`
  - `crowdsecurity/http-probing`
  - Multiple admin/CVE scenarios
- **Detection Logic**: 10+ different paths accessed within 30 seconds
- **Why It Matters**: Scanners are the first step of most attacks

### Demo Talking Points
- "This mimics tools like Nikto or Nessus scanning your website"
- "Notice how it checks for WordPress, phpMyAdmin, Git files, backups"
- "Legitimate users navigate through your site logically"
- "Scanners jump between unrelated paths rapidly - dead giveaway"

---

## 7. SQL Injection Attempts (`attack_sql_injection.sh`)

### What It Does
Sends 20 requests with SQL injection payloads in:
- URL parameters: `?q=' OR '1'='1`
- Form fields: `username=' OR 1=1--`

Common payloads:
- `' OR '1'='1` - Authentication bypass
- `'; DROP TABLE users--` - Destructive command
- `UNION SELECT NULL` - Data extraction

### Real-World Scenario
- **Database compromise** - stealing user credentials
- **Data exfiltration** - downloading entire databases
- **Authentication bypass** - logging in without password
- Famous attacks: Sony (2011), Ashley Madison (2015)

### How It Works
```bash
payloads=("' OR '1'='1" "'; DROP TABLE users--" ...)
for payload in "${payloads[@]}"; do
  curl "${TARGET}/search?q=${payload}"
  curl -X POST "${TARGET}/login" -d "username=${payload}"
done
```

### What CrowdSec Detects
- **Scenario Triggered**: `crowdsecurity/http-sqli-probing`
- **Detection Logic**: SQL keywords in URLs/POST data
- **Why It Matters**: #1 web application vulnerability (OWASP Top 10)

### Demo Talking Points
- "SQL injection allows attackers to run database commands"
- "Could steal passwords, credit cards, or delete entire databases"
- "The famous 'OR 1=1 always returns true, bypassing login"
- "CrowdSec detects SQL patterns before they reach your database"

---

## 8. XSS (Cross-Site Scripting) (`attack_xss.sh`)

### What It Does
Sends 20 requests with JavaScript injection payloads:
- `<script>alert('XSS')</script>` - Classic XSS
- `<img src=x onerror=alert('XSS')>` - Image tag injection
- `<svg/onload=alert('XSS')>` - SVG-based XSS
- `javascript:alert('XSS')` - Protocol handler
- `<iframe src='javascript:alert(1)'>` - Frame injection

### Real-World Scenario
- **Session hijacking** - stealing user cookies
- **Phishing** - creating fake login forms
- **Malware distribution** - redirecting to malicious sites
- **Website defacement** - modifying page content

### How It Works
```bash
payloads=("<script>alert('XSS')</script>" "<img src=x onerror=alert('XSS')>" ...)
for payload in "${payloads[@]}"; do
  curl "${TARGET}/search?q=${payload}"
  curl -X POST "${TARGET}/comment" -d "comment=${payload}"
done
```

### What CrowdSec Detects
- **Scenario Triggered**: `crowdsecurity/http-xss-probing`
- **Detection Logic**: HTML/JavaScript patterns in user input
- **Why It Matters**: Can compromise other users' accounts

### Demo Talking Points
- "XSS allows attackers to run JavaScript in victim browsers"
- "Could steal authentication cookies or credit card data"
- "These payloads try different techniques to bypass filters"
- "CrowdSec blocks the attacker before they find a working payload"

---

## Demo Flow Recommendations

### 1. Start Clean
```bash
# Clear previous bans
docker-compose exec crowdsec cscli decisions delete --all

# Check initial access works
docker-compose exec attacker curl http://openresty
```

### 2. Run Attacks in Order (from easiest to hardest)
1. **404 Flood** - Easiest to explain, quick detection
2. **Sensitive Files** - Show specific paths attackers target
3. **Scanner Detection** - Most comprehensive/realistic
4. **Login Brute Force** - Very relatable (everyone knows passwords)
5. **POST Flood** - Show API protection
6. **HTTP Method Abuse** - More technical, explain RESTful APIs

### 3. After Each Attack, Show:
```bash
# Check if blocked
docker-compose exec attacker curl http://openresty
# Should return 403 after 2-3 attacks

# Show the decision
docker-compose exec crowdsec cscli decisions list

# Show alert details
docker-compose exec crowdsec cscli alerts list
docker-compose exec crowdsec cscli alerts inspect <ID>
```

### 4. Show Kibana Visualizations
- Navigate to Kibana dashboards
- Point out attack sources, top blocked IPs
- Show timeline of events
- Demonstrate log correlation

### 5. Explain the Architecture
```
Attacker → OpenResty → Web Server
              ↓
        CrowdSec Bouncer
              ↓
        CrowdSec (Detection Engine)
              ↓
        Logstash → Elasticsearch → Kibana
```

---

## Key Metrics to Mention

### Detection Speed
- "CrowdSec detects attacks in real-time (< 5 seconds)"
- "Blocked before significant damage occurs"

### Accuracy
- "No false positives - legitimate users unaffected"
- "Pattern-based detection, not single-event triggers"

### Scale
- "Protects against thousands of attack techniques"
- "58 built-in scenarios + 6 custom ones"
- "Community-driven threat intelligence"

---

## Common Questions & Answers

**Q: What if legitimate user gets blocked?**
A: Unlikely due to thresholds, but admins can whitelist IPs or use `cscli decisions delete`

**Q: How is this different from a WAF?**
A: CrowdSec is behavioral (pattern-based), WAF is signature-based. CrowdSec also shares threat intel.

**Q: Can attackers bypass this?**
A: They'd need to slow down attacks significantly, making them impractical. Plus IP rotation gets expensive.

**Q: Performance impact?**
A: Minimal - logs analyzed asynchronously. Bouncer cache makes blocking instant.

**Q: Why ELK Stack?**
A: Centralized logging, powerful analytics, beautiful visualizations, security correlation.

---

## Pro Tips for Presentation

1. **Practice the demo** - Run through it 2-3 times beforehand
2. **Have backup terminal windows** ready with commands
3. **Take screenshots** in case live demo fails
4. **Start with simple attacks**, build complexity
5. **Relate to real news** - mention recent breaches
6. **Show both attacker AND defender perspective**
7. **End with "What happens without CrowdSec"** - attacks succeed

Good luck with your presentation! 🚀
