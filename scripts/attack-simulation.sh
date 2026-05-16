#!/usr/bin/env bash
# =============================================================================
# attack-simulation.sh — Generate security events for Wazuh to detect
# =============================================================================
# Runs simulated attacks against the agent VMs to produce real alerts
# in the Wazuh Dashboard. Run this AFTER deployment is complete.
#
# Usage: ./attack-simulation.sh <agent-ip>
# =============================================================================

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <target-agent-ip>"
    echo "Example: $0 34.76.xxx.xxx"
    exit 1
fi

TARGET_IP="$1"
SSH_KEY="$HOME/.ssh/gcp_key"
SSH_USER="abdou"

echo "=============================================="
echo "  SIEM Lab — Attack Simulation"
echo "  Target: ${TARGET_IP}"
echo "=============================================="
echo ""

# --------------- Test 1: SSH Brute Force Simulation ---------------
echo "[1/5] Simulating SSH brute-force (failed login attempts)..."
for i in $(seq 1 8); do
    ssh -o StrictHostKeyChecking=no \
        -o BatchMode=yes \
        -o ConnectTimeout=3 \
        -i /dev/null \
        "fakeuser${i}@${TARGET_IP}" 2>/dev/null || true
done
echo "      -> 8 failed SSH attempts sent (should trigger rule 5712)"
echo ""

# --------------- Test 2: File Integrity Monitoring (FIM) ---------------
echo "[2/5] Triggering File Integrity Monitoring alerts..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "${SSH_USER}@${TARGET_IP}" << 'REMOTE_FIM'
# Create and delete a suspicious file in a monitored directory
sudo touch /etc/siem-test-file.conf
sleep 2
sudo bash -c 'echo "malicious_config=true" >> /etc/siem-test-file.conf'
sleep 2
sudo rm -f /etc/siem-test-file.conf
REMOTE_FIM
echo "      -> FIM events generated in /etc (should trigger syscheck alerts)"
echo ""

# --------------- Test 3: Unauthorized sudo attempts ---------------
echo "[3/5] Simulating unauthorized sudo attempts..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "${SSH_USER}@${TARGET_IP}" << 'REMOTE_SUDO'
# Try sudo commands that will be logged
sudo -u nobody ls /root 2>/dev/null || true
sudo cat /etc/shadow 2>/dev/null || true
REMOTE_SUDO
echo "      -> Sudo events logged (should appear in auth.log alerts)"
echo ""

# --------------- Test 4: Suspicious Process Execution ---------------
echo "[4/5] Simulating suspicious process activity..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "${SSH_USER}@${TARGET_IP}" << 'REMOTE_PROC'
# Commands that trigger rootcheck/anomaly alerts
sudo netstat -tulnp 2>/dev/null || sudo ss -tulnp
curl -s http://example.com > /dev/null 2>&1 || true
wget -q http://example.com -O /tmp/test_download 2>/dev/null || true
rm -f /tmp/test_download
REMOTE_PROC
echo "      -> Suspicious commands executed (should generate audit events)"
echo ""

# --------------- Test 5: Docker Activity ---------------
echo "[5/5] Simulating Docker container activity..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "${SSH_USER}@${TARGET_IP}" << 'REMOTE_DOCKER'
# Docker operations that get logged
docker pull alpine:latest 2>/dev/null || true
docker run --rm --name siem-test alpine echo "SIEM test container" 2>/dev/null || true
REMOTE_DOCKER
echo "      -> Docker events generated (should appear in Docker log monitoring)"
echo ""

echo "=============================================="
echo "  Simulation Complete!"
echo "=============================================="
echo ""
echo "  Check the Wazuh Dashboard for new alerts:"
echo "  -> Security Events module"
echo "  -> File Integrity Monitoring module"
echo "  -> Agents > [agent-name] > Security Events"
echo ""
echo "  Note: Alerts may take 1-2 minutes to appear."
echo "=============================================="
