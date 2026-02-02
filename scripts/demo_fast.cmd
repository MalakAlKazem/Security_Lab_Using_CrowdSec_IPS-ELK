@echo off
REM CrowdSec Demo - No Restarts Between Attacks (Faster & More Reliable)
REM All attacks accumulate - shows combined effect
REM Date: February 2, 2026

echo.
echo ========================================
echo CrowdSec IPS + ELK Stack - Live Attack Demo
echo ========================================
echo.
echo This demo shows 6 attacks executed rapidly.
echo All attacks accumulate - more realistic scenario!
echo.

echo Initial cleanup...
docker-compose exec crowdsec cscli decisions delete --all
docker-compose exec openresty sh -c "echo '' > /var/log/nginx/access.log"
echo Restarting CrowdSec...
docker-compose restart crowdsec >nul 2>&1
echo Waiting 12 seconds for CrowdSec to fully start...
timeout /t 12 >nul
echo Ready!
echo.

REM ============================================
REM ATTACK 1: HTTP 404 Flood
REM ============================================
echo.
echo ========================================
echo ATTACK 1/6: HTTP 404 Flood
echo ========================================
echo Sends 50 rapid requests to non-existent pages
echo.
docker-compose exec attacker bash /scripts/attack_404_flood.sh
echo.
echo Waiting 10 seconds for CrowdSec detection and bouncer sync...
timeout /t 10 >nul
echo.
echo === Checking Block Status ===
docker-compose exec attacker curl -s -I http://openresty 2>nul | findstr "HTTP"
echo.
echo Press ENTER to continue...
pause >nul

REM ============================================
REM ATTACK 2: Sensitive Files
REM ============================================
echo.
echo ========================================
echo ATTACK 2/6: Sensitive Files Access  
echo ========================================
echo Probes for /admin, /.env, /backup.sql, etc.
echo.
docker-compose exec attacker bash /scripts/attack_sensitive_paths.sh
echo.
echo Waiting 10 seconds...
timeout /t 10 >nul
echo.
echo === Checking Block Status ===
docker-compose exec attacker curl -s -I http://openresty 2>nul | findstr "HTTP"
echo.
echo Press ENTER to continue...
pause >nul

REM ============================================
REM ATTACK 3: POST Flood
REM ============================================
echo.
echo ========================================
echo ATTACK 3/6: HTTP POST Flood
echo ========================================
echo Floods server with 25 POST requests
echo.
docker-compose exec attacker bash /scripts/attack_post_flood.sh
echo.
echo Waiting 10 seconds...
timeout /t 10 >nul
echo.
echo === Checking Block Status ===
docker-compose exec attacker curl -s -I http://openresty 2>nul | findstr "HTTP"
echo.
echo Press ENTER to continue...
pause >nul

REM ============================================
REM ATTACK 4: Method Abuse
REM ============================================
echo.
echo ========================================
echo ATTACK 4/6: HTTP Method Abuse
echo ========================================
echo Uses unusual HTTP verbs (DELETE, PUT, TRACE, PATCH)
echo.
docker-compose exec attacker bash /scripts/attack_method_abuse.sh
echo.
echo Waiting 15 seconds (this attack has delays)...
timeout /t 15 >nul
echo.
echo === Checking Block Status ===
docker-compose exec attacker curl -s -I http://openresty 2>nul | findstr "HTTP"
echo.
echo Press ENTER to continue...
pause >nul

REM ============================================
REM ATTACK 5: Scanner
REM ============================================
echo.
echo ========================================
echo ATTACK 5/6: Path Scanner
echo ========================================
echo Scans for hidden directories and files
echo.
docker-compose exec attacker bash /scripts/attack_scanner_v3.sh
echo.
echo Waiting 10 seconds...
timeout /t 10 >nul
echo.
echo === Checking Block Status ===
docker-compose exec attacker curl -s -I http://openresty 2>nul | findstr "HTTP"
echo.
echo Press ENTER to continue...
pause >nul

REM ============================================
REM ATTACK 6: SQL Injection
REM ============================================
echo.
echo ========================================
echo ATTACK 6/6: SQL Injection
echo ========================================
echo Tries SQL payloads: UNION SELECT, OR 1=1, admin'--
echo.
docker-compose exec attacker bash /scripts/attack_sql_injection_final.sh
echo.
echo Waiting 10 seconds...
timeout /t 10 >nul
echo.
echo === Checking Block Status ===
docker-compose exec attacker curl -s -I http://openresty 2>nul | findstr "HTTP"
echo.

REM ============================================
REM SHOW ALL RESULTS
REM ============================================
echo.
echo ========================================
echo ALL ATTACKS COMPLETE - FINAL RESULTS
echo ========================================
echo.
echo Waiting 5 more seconds for all processing...
timeout /t 5 >nul
echo.

echo === ALL DECISIONS/BANS ===
docker-compose exec crowdsec cscli decisions list
echo.

echo === ALL ALERTS (Last 10) ===
docker-compose exec crowdsec cscli alerts list --limit 10
echo.

echo === FINAL BLOCK CHECK ===
docker-compose exec attacker curl -s -I http://openresty 2>nul | findstr "HTTP"
echo If you see 403 Forbidden above, attacks are blocked!
echo.

echo.
echo ========================================
echo DEMO COMPLETE!
echo ========================================
echo.
echo Summary:
echo - 6 attacks executed
echo - Multiple CrowdSec scenarios triggered
echo - Attacker IP banned for 4 hours
echo - Check Kibana: http://localhost:5601
echo.
pause
