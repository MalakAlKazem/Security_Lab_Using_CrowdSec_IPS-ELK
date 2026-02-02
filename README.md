# CrowdSec IPS + ELK Stack Demo

A complete demonstration environment showing CrowdSec's Intrusion Prevention System integrated with the ELK Stack (Elasticsearch, Logstash, Kibana) for real-time attack detection, blocking, and visualization.

## 🎯 What This Does

- **CrowdSec** detects and blocks malicious behavior (SQL injection, brute force, scanners, etc.)
- **OpenResty** with Lua bouncer blocks attackers at the web server
- **Filebeat** ships NGINX logs to Logstash
- **Logstash** enriches logs with CrowdSec decisions
- **Kibana** visualizes attacks and blocks in real-time

## 📋 Prerequisites

- Docker & Docker Compose
- Git
- Bash (for attack scripts)

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo-url>
cd crowdsec-ips-elk
cp .env.example .env
```

### 2. Generate CrowdSec Bouncer Key

```bash
# Start only CrowdSec first
docker-compose up -d crowdsec

# Generate bouncer key
docker exec crowdsec cscli bouncers add openresty-bouncer

# Copy the generated key and paste it in .env file
# Replace: CROWDSEC_BOUNCER_KEY=your_bouncer_key_here
```

### 3. Start All Services

```bash
docker-compose up -d
```

### 4. Access Kibana

Open http://localhost:5601 in your browser

### 5. Run Attack Simulations

```bash
# Enter the attacker container
docker exec -it attacker bash

# Run individual attacks
cd /scripts
bash attack_sql_injection_final.sh
bash attack_login_bruteforce.sh
bash attack_scanner_v3.sh

# Or run all attacks
bash attack_all.sh
```

## 📁 Project Structure

```
├── crowdsec/              # CrowdSec custom scenarios and parsers
├── openresty/            # NGINX + Lua bouncer configuration
├── logstash/             # Logstash pipelines for log processing
├── filebeat/             # Filebeat configuration
├── web/                  # Demo web application
├── scripts/              # Attack simulation scripts
├── docker-compose.yml    # Main orchestration file
├── .env.example          # Environment variables template
└── ATTACK_EXPLANATIONS.md # Detailed attack descriptions
```

## 🛡️ Custom CrowdSec Scenarios

1. **SQL Injection Detection** - Detects SQL injection attempts
2. **Login Brute Force** - Blocks credential stuffing attacks
3. **404 Flood** - Identifies scanning behavior
4. **Sensitive File Access** - Protects config files and admin panels
5. **HTTP Method Abuse** - Blocks dangerous HTTP methods
6. **POST Flood** - Prevents POST request floods
7. **Scanner Detection** - Identifies automated scanning tools

## 📊 What You'll See in Kibana

- Real-time attack attempts
- Blocked IPs and decision types
- Attack patterns and trends
- Geographic distribution of attacks
- Response times and status codes

## 🔧 Useful Commands

```bash
# View CrowdSec decisions
docker exec crowdsec cscli decisions list

# Check banned IPs
docker exec crowdsec cscli decisions list --type ban

# View CrowdSec alerts
docker exec crowdsec cscli alerts list

# Verify OpenResty bouncer status
docker logs openresty

# Test if attacker is blocked
docker exec attacker curl -I http://web
```

## 🧹 Cleanup

```bash
# Stop all services
docker-compose down

# Remove volumes (complete cleanup)
docker-compose down -v
```

## ⚠️ Security Notes

- This is a **demonstration environment** only
- The .env file contains secrets and should never be committed
- Regenerate bouncer keys for production use
- Elasticsearch has security disabled for simplicity

## 📖 Learn More

- See [ATTACK_EXPLANATIONS.md](ATTACK_EXPLANATIONS.md) for detailed attack analysis
- See [scripts/README.md](scripts/README.md) for attack script documentation

## 🤝 Contributing

Feel free to open issues or submit pull requests!

## 📝 License

[Your chosen license]
