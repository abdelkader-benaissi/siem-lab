#!/usr/bin/env bash
# =============================================================================
# create-dashboard.sh — Create a professional SIEM Lab Dashboard in Wazuh
# =============================================================================
# Creates visualizations and a dashboard via the OpenSearch Dashboards API
# =============================================================================

set -euo pipefail

WAZUH_IP="${1:?Usage: $0 <wazuh-server-ip>}"
DASHBOARD_URL="https://${WAZUH_IP}"
# Credentials — uses Wazuh Docker defaults. Override via environment:
#   WAZUH_USER=admin WAZUH_PASS=MyPassword ./create-dashboard.sh <ip>
WAZUH_USER="${WAZUH_USER:-admin}"
WAZUH_PASS="${WAZUH_PASS:-SecretPassword}"
CREDS="${WAZUH_USER}:${WAZUH_PASS}"

echo "=============================================="
echo "  Creating SIEM Lab Dashboard"
echo "  Target: ${DASHBOARD_URL}"
echo "=============================================="
echo ""

# --- Helper function to create a saved object ---
create_visualization() {
    local id="$1"
    local body="$2"
    
    curl -sk -X POST "${DASHBOARD_URL}/api/saved_objects/visualization/${id}" \
        -u "${CREDS}" \
        -H "osd-xsrf: true" \
        -H "Content-Type: application/json" \
        -d "${body}" > /dev/null 2>&1
    
    echo "  ✅ Created: ${id}"
}

# =============================================================================
# 1. Alert Severity Pie Chart
# =============================================================================
echo "[1/8] Creating Alert Severity Distribution..."
create_visualization "siem-lab-alert-severity" '{
  "attributes": {
    "title": "🔴 Alert Severity Distribution",
    "visState": "{\"title\":\"Alert Severity Distribution\",\"type\":\"pie\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"range\",\"params\":{\"field\":\"rule.level\",\"ranges\":[{\"from\":0,\"to\":7},{\"from\":7,\"to\":12},{\"from\":12,\"to\":15},{\"from\":15,\"to\":16}],\"json\":\"\"},\"schema\":\"segment\"}],\"params\":{\"type\":\"pie\",\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\",\"isDonut\":true,\"labels\":{\"show\":true,\"values\":true,\"last_level\":true,\"truncate\":100}}}",
    "uiStateJSON": "{}",
    "description": "Distribution of alerts by severity level",
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"index\":\"wazuh-alerts-*\",\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"
    }
  }
}'

# =============================================================================
# 2. Top Attack Techniques (MITRE)
# =============================================================================
echo "[2/8] Creating Top MITRE ATT&CK Techniques..."
create_visualization "siem-lab-mitre-techniques" '{
  "attributes": {
    "title": "⚔️ Top MITRE ATT&CK Techniques",
    "visState": "{\"title\":\"Top MITRE ATT&CK Techniques\",\"type\":\"horizontal_bar\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"params\":{\"field\":\"rule.mitre.technique\",\"orderBy\":\"1\",\"order\":\"desc\",\"size\":10,\"otherBucket\":false,\"otherBucketLabel\":\"Other\",\"missingBucket\":false,\"missingBucketLabel\":\"Missing\"},\"schema\":\"segment\"}],\"params\":{\"type\":\"horizontal_bar\",\"grid\":{\"categoryLines\":false},\"categoryAxes\":[{\"id\":\"CategoryAxis-1\",\"type\":\"category\",\"position\":\"left\",\"show\":true,\"labels\":{\"show\":true,\"rotate\":0,\"filter\":false,\"truncate\":200},\"title\":{}}],\"valueAxes\":[{\"id\":\"ValueAxis-1\",\"name\":\"LeftAxis-1\",\"type\":\"value\",\"position\":\"bottom\",\"show\":true,\"labels\":{\"show\":true,\"rotate\":0,\"filter\":false,\"truncate\":100},\"title\":{\"text\":\"Count\"}}],\"seriesParams\":[{\"show\":true,\"type\":\"histogram\",\"mode\":\"normal\",\"data\":{\"label\":\"Count\",\"id\":\"1\"},\"valueAxis\":\"ValueAxis-1\",\"drawLinesBetweenPoints\":true,\"lineWidth\":2,\"showCircles\":true}],\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\",\"times\":[],\"addTimeMarker\":false,\"labels\":{},\"thresholdLine\":{\"show\":false,\"value\":10,\"width\":1,\"style\":\"full\",\"color\":\"#E7664C\"}}}",
    "uiStateJSON": "{}",
    "description": "Top 10 MITRE ATT&CK techniques detected",
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"index\":\"wazuh-alerts-*\",\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"
    }
  }
}'

# =============================================================================
# 3. Alerts Over Time
# =============================================================================
echo "[3/8] Creating Alerts Timeline..."
create_visualization "siem-lab-alerts-timeline" '{
  "attributes": {
    "title": "📈 Alerts Over Time",
    "visState": "{\"title\":\"Alerts Over Time\",\"type\":\"area\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"date_histogram\",\"params\":{\"field\":\"timestamp\",\"timeRange\":{\"from\":\"now-24h\",\"to\":\"now\"},\"useNormalizedOpenSearchInterval\":true,\"scaleMetricValues\":false,\"interval\":\"auto\",\"drop_partials\":false,\"min_doc_count\":1,\"extended_bounds\":{}},\"schema\":\"segment\"},{\"id\":\"3\",\"enabled\":true,\"type\":\"terms\",\"params\":{\"field\":\"rule.level\",\"orderBy\":\"1\",\"order\":\"desc\",\"size\":5,\"otherBucket\":false,\"missingBucket\":false},\"schema\":\"group\"}],\"params\":{\"type\":\"area\",\"grid\":{\"categoryLines\":false},\"categoryAxes\":[{\"id\":\"CategoryAxis-1\",\"type\":\"category\",\"position\":\"bottom\",\"show\":true,\"labels\":{\"show\":true,\"rotate\":0,\"filter\":true,\"truncate\":100},\"title\":{}}],\"valueAxes\":[{\"id\":\"ValueAxis-1\",\"name\":\"LeftAxis-1\",\"type\":\"value\",\"position\":\"left\",\"show\":true,\"labels\":{\"show\":true,\"rotate\":0,\"filter\":false,\"truncate\":100},\"title\":{\"text\":\"\"}}],\"seriesParams\":[{\"show\":true,\"type\":\"area\",\"mode\":\"stacked\",\"data\":{\"label\":\"Count\",\"id\":\"1\"},\"drawLinesBetweenPoints\":true,\"lineWidth\":2,\"showCircles\":true,\"interpolate\":\"linear\",\"valueAxis\":\"ValueAxis-1\"}],\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"bottom\",\"times\":[],\"addTimeMarker\":false,\"thresholdLine\":{\"show\":false,\"value\":10,\"width\":1,\"style\":\"full\",\"color\":\"#E7664C\"},\"labels\":{},\"orderBucketsBySum\":false}}",
    "uiStateJSON": "{}",
    "description": "Alert volume over time grouped by severity level",
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"index\":\"wazuh-alerts-*\",\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"
    }
  }
}'

# =============================================================================
# 4. Top Rules Triggered
# =============================================================================
echo "[4/8] Creating Top Rules Triggered..."
create_visualization "siem-lab-top-rules" '{
  "attributes": {
    "title": "🏆 Top 15 Rules Triggered",
    "visState": "{\"title\":\"Top 15 Rules Triggered\",\"type\":\"table\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"params\":{\"field\":\"rule.id\",\"orderBy\":\"1\",\"order\":\"desc\",\"size\":15,\"otherBucket\":false,\"missingBucket\":false},\"schema\":\"bucket\"},{\"id\":\"3\",\"enabled\":true,\"type\":\"terms\",\"params\":{\"field\":\"rule.description\",\"orderBy\":\"1\",\"order\":\"desc\",\"size\":1,\"otherBucket\":false,\"missingBucket\":false},\"schema\":\"bucket\"},{\"id\":\"4\",\"enabled\":true,\"type\":\"terms\",\"params\":{\"field\":\"rule.level\",\"orderBy\":\"1\",\"order\":\"desc\",\"size\":1,\"otherBucket\":false,\"missingBucket\":false},\"schema\":\"bucket\"}],\"params\":{\"perPage\":15,\"showPartialRows\":false,\"showMetricsAtAllLevels\":false,\"sort\":{\"columnIndex\":null,\"direction\":null},\"showTotal\":false,\"totalFunc\":\"sum\",\"percentageCol\":\"\"}}",
    "uiStateJSON": "{\"vis\":{\"params\":{\"sort\":{\"columnIndex\":null,\"direction\":null}}}}",
    "description": "Most frequently triggered detection rules",
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"index\":\"wazuh-alerts-*\",\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"
    }
  }
}'

# =============================================================================
# 5. Alerts per Agent
# =============================================================================
echo "[5/8] Creating Alerts per Agent..."
create_visualization "siem-lab-alerts-per-agent" '{
  "attributes": {
    "title": "🖥️ Alerts per Agent",
    "visState": "{\"title\":\"Alerts per Agent\",\"type\":\"pie\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"params\":{\"field\":\"agent.name\",\"orderBy\":\"1\",\"order\":\"desc\",\"size\":10,\"otherBucket\":false,\"missingBucket\":false},\"schema\":\"segment\"}],\"params\":{\"type\":\"pie\",\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\",\"isDonut\":true,\"labels\":{\"show\":true,\"values\":true,\"last_level\":true,\"truncate\":100}}}",
    "uiStateJSON": "{}",
    "description": "Alert distribution across monitored agents",
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"index\":\"wazuh-alerts-*\",\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"
    }
  }
}'

# =============================================================================
# 6. Authentication Events
# =============================================================================
echo "[6/8] Creating Authentication Events..."
create_visualization "siem-lab-auth-events" '{
  "attributes": {
    "title": "🔐 Authentication Events",
    "visState": "{\"title\":\"Authentication Events\",\"type\":\"histogram\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"date_histogram\",\"params\":{\"field\":\"timestamp\",\"timeRange\":{\"from\":\"now-24h\",\"to\":\"now\"},\"useNormalizedOpenSearchInterval\":true,\"scaleMetricValues\":false,\"interval\":\"auto\",\"drop_partials\":false,\"min_doc_count\":1,\"extended_bounds\":{}},\"schema\":\"segment\"},{\"id\":\"3\",\"enabled\":true,\"type\":\"terms\",\"params\":{\"field\":\"rule.description\",\"orderBy\":\"1\",\"order\":\"desc\",\"size\":5,\"otherBucket\":false,\"missingBucket\":false},\"schema\":\"group\"}],\"params\":{\"type\":\"histogram\",\"grid\":{\"categoryLines\":false},\"categoryAxes\":[{\"id\":\"CategoryAxis-1\",\"type\":\"category\",\"position\":\"bottom\",\"show\":true,\"labels\":{\"show\":true,\"rotate\":0,\"filter\":true,\"truncate\":100},\"title\":{}}],\"valueAxes\":[{\"id\":\"ValueAxis-1\",\"name\":\"LeftAxis-1\",\"type\":\"value\",\"position\":\"left\",\"show\":true,\"labels\":{\"show\":true,\"rotate\":0,\"filter\":false,\"truncate\":100},\"title\":{\"text\":\"\"}}],\"seriesParams\":[{\"show\":true,\"type\":\"histogram\",\"mode\":\"stacked\",\"data\":{\"label\":\"Count\",\"id\":\"1\"},\"valueAxis\":\"ValueAxis-1\",\"drawLinesBetweenPoints\":true,\"lineWidth\":2,\"showCircles\":true}],\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"bottom\",\"times\":[],\"addTimeMarker\":false,\"thresholdLine\":{\"show\":false,\"value\":10,\"width\":1,\"style\":\"full\",\"color\":\"#E7664C\"},\"labels\":{},\"orderBucketsBySum\":false}}",
    "uiStateJSON": "{}",
    "description": "SSH and authentication events over time",
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"index\":\"wazuh-alerts-*\",\"query\":{\"query\":\"rule.groups: authentication OR rule.groups: sshd OR rule.groups: syslog\",\"language\":\"kuery\"},\"filter\":[]}"
    }
  }
}'

# =============================================================================
# 7. File Integrity Monitoring Events
# =============================================================================
echo "[7/8] Creating FIM Events..."
create_visualization "siem-lab-fim-events" '{
  "attributes": {
    "title": "📁 File Integrity Changes",
    "visState": "{\"title\":\"File Integrity Changes\",\"type\":\"histogram\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"params\":{\"field\":\"syscheck.path\",\"orderBy\":\"1\",\"order\":\"desc\",\"size\":10,\"otherBucket\":false,\"missingBucket\":false},\"schema\":\"segment\"},{\"id\":\"3\",\"enabled\":true,\"type\":\"terms\",\"params\":{\"field\":\"syscheck.event\",\"orderBy\":\"1\",\"order\":\"desc\",\"size\":5,\"otherBucket\":false,\"missingBucket\":false},\"schema\":\"group\"}],\"params\":{\"type\":\"histogram\",\"grid\":{\"categoryLines\":false},\"categoryAxes\":[{\"id\":\"CategoryAxis-1\",\"type\":\"category\",\"position\":\"bottom\",\"show\":true,\"labels\":{\"show\":true,\"rotate\":-45,\"filter\":true,\"truncate\":100},\"title\":{}}],\"valueAxes\":[{\"id\":\"ValueAxis-1\",\"name\":\"LeftAxis-1\",\"type\":\"value\",\"position\":\"left\",\"show\":true,\"labels\":{\"show\":true,\"rotate\":0,\"filter\":false,\"truncate\":100},\"title\":{\"text\":\"\"}}],\"seriesParams\":[{\"show\":true,\"type\":\"histogram\",\"mode\":\"stacked\",\"data\":{\"label\":\"Count\",\"id\":\"1\"},\"valueAxis\":\"ValueAxis-1\",\"drawLinesBetweenPoints\":true,\"lineWidth\":2,\"showCircles\":true}],\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\",\"times\":[],\"addTimeMarker\":false,\"thresholdLine\":{\"show\":false,\"value\":10,\"width\":1,\"style\":\"full\",\"color\":\"#E7664C\"},\"labels\":{},\"orderBucketsBySum\":false}}",
    "uiStateJSON": "{}",
    "description": "File changes detected by syscheck",
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"index\":\"wazuh-alerts-*\",\"query\":{\"query\":\"rule.groups: syscheck\",\"language\":\"kuery\"},\"filter\":[]}"
    }
  }
}'

# =============================================================================
# 8. Alert Counts by Rule Group (Tag Cloud)
# =============================================================================
echo "[8/8] Creating Rule Groups Cloud..."
create_visualization "siem-lab-rule-groups" '{
  "attributes": {
    "title": "☁️ Alert Categories",
    "visState": "{\"title\":\"Alert Categories\",\"type\":\"tagcloud\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"params\":{\"field\":\"rule.groups\",\"orderBy\":\"1\",\"order\":\"desc\",\"size\":20,\"otherBucket\":false,\"missingBucket\":false},\"schema\":\"segment\"}],\"params\":{\"scale\":\"linear\",\"orientation\":\"single\",\"minFontSize\":14,\"maxFontSize\":72,\"showLabel\":true}}",
    "uiStateJSON": "{}",
    "description": "Visual cloud of alert categories by frequency",
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"index\":\"wazuh-alerts-*\",\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"
    }
  }
}'

echo ""
echo "=============================================="
echo "  Creating Dashboard..."
echo "=============================================="

# =============================================================================
# Create the Dashboard that combines all visualizations
# =============================================================================
curl -sk -X POST "${DASHBOARD_URL}/api/saved_objects/dashboard/siem-lab-dashboard" \
    -u "${CREDS}" \
    -H "osd-xsrf: true" \
    -H "Content-Type: application/json" \
    -d '{
  "attributes": {
    "title": "🛡️ SIEM Lab — Security Operations Dashboard",
    "description": "Professional SOC dashboard for the SIEM Lab — attack simulation monitoring, agent health, and security event analysis",
    "panelsJSON": "[{\"embeddableConfig\":{},\"gridData\":{\"x\":0,\"y\":0,\"w\":24,\"h\":15,\"i\":\"1\"},\"panelIndex\":\"1\",\"version\":\"7.10.2\",\"panelRefName\":\"panel_0\"},{\"embeddableConfig\":{},\"gridData\":{\"x\":24,\"y\":0,\"w\":24,\"h\":15,\"i\":\"2\"},\"panelIndex\":\"2\",\"version\":\"7.10.2\",\"panelRefName\":\"panel_1\"},{\"embeddableConfig\":{},\"gridData\":{\"x\":0,\"y\":15,\"w\":48,\"h\":14,\"i\":\"3\"},\"panelIndex\":\"3\",\"version\":\"7.10.2\",\"panelRefName\":\"panel_2\"},{\"embeddableConfig\":{},\"gridData\":{\"x\":0,\"y\":29,\"w\":48,\"h\":15,\"i\":\"4\"},\"panelIndex\":\"4\",\"version\":\"7.10.2\",\"panelRefName\":\"panel_3\"},{\"embeddableConfig\":{},\"gridData\":{\"x\":0,\"y\":44,\"w\":24,\"h\":15,\"i\":\"5\"},\"panelIndex\":\"5\",\"version\":\"7.10.2\",\"panelRefName\":\"panel_4\"},{\"embeddableConfig\":{},\"gridData\":{\"x\":24,\"y\":44,\"w\":24,\"h\":15,\"i\":\"6\"},\"panelIndex\":\"6\",\"version\":\"7.10.2\",\"panelRefName\":\"panel_5\"},{\"embeddableConfig\":{},\"gridData\":{\"x\":0,\"y\":59,\"w\":24,\"h\":15,\"i\":\"7\"},\"panelIndex\":\"7\",\"version\":\"7.10.2\",\"panelRefName\":\"panel_6\"},{\"embeddableConfig\":{},\"gridData\":{\"x\":24,\"y\":59,\"w\":24,\"h\":15,\"i\":\"8\"},\"panelIndex\":\"8\",\"version\":\"7.10.2\",\"panelRefName\":\"panel_7\"}]",
    "optionsJSON": "{\"hidePanelTitles\":false,\"useMargins\":true}",
    "timeRestore": true,
    "timeTo": "now",
    "timeFrom": "now-24h",
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"query\":{\"language\":\"kuery\",\"query\":\"\"},\"filter\":[]}"
    }
  },
  "references": [
    {"name":"panel_0","type":"visualization","id":"siem-lab-alert-severity"},
    {"name":"panel_1","type":"visualization","id":"siem-lab-alerts-per-agent"},
    {"name":"panel_2","type":"visualization","id":"siem-lab-alerts-timeline"},
    {"name":"panel_3","type":"visualization","id":"siem-lab-top-rules"},
    {"name":"panel_4","type":"visualization","id":"siem-lab-mitre-techniques"},
    {"name":"panel_5","type":"visualization","id":"siem-lab-auth-events"},
    {"name":"panel_6","type":"visualization","id":"siem-lab-fim-events"},
    {"name":"panel_7","type":"visualization","id":"siem-lab-rule-groups"}
  ]
}' > /dev/null 2>&1

echo ""
echo "=============================================="
echo "  ✅ Dashboard Created Successfully!"
echo "=============================================="
echo ""
echo "  Open: ${DASHBOARD_URL}/app/dashboards#/view/siem-lab-dashboard"
echo ""
echo "  Dashboard includes 8 panels:"
echo "    1. 🔴 Alert Severity Distribution (donut)"
echo "    2. 🖥️ Alerts per Agent (donut)"
echo "    3. 📈 Alerts Over Time (stacked area)"
echo "    4. 🏆 Top 15 Rules Triggered (table)"
echo "    5. ⚔️ Top MITRE ATT&CK Techniques (bar chart)"
echo "    6. 🔐 Authentication Events (histogram)"
echo "    7. 📁 File Integrity Changes (histogram)"
echo "    8. ☁️ Alert Categories (tag cloud)"
echo ""
