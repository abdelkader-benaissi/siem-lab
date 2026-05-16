# SIEM Lab — Architecture Design

## Design Decisions

### Why Wazuh?
- Lightweight enough for GCP free-trial budget (8GB all-in-one)
- Covers HIDS, FIM, SCA, log analysis, and active response
- Official Docker deployment simplifies automation
- Strong community and enterprise adoption
- Directly relevant to Security Engineering roles

### Why 4 VMs (not 5+)?
- GCP free trial limits to 8 concurrent vCPUs
- 4 VMs = 5 vCPUs total (2 + 1 + 1 + 1), well within limits
- Each VM has a distinct purpose and OS
- Can easily scale by adding more agent definitions to Terraform

### Why Docker for Wazuh Server?
- Faster deployment (~5 min vs ~20 min bare-metal)
- Clean teardown — no leftover packages
- Version-pinned and reproducible
- Official wazuh-docker repo is well-maintained

### Why Native Agent (not Docker) for Agents?
- Native agents have better OS-level visibility (FIM, rootcheck, SCA)
- Docker containers can't monitor host-level file integrity as effectively
- Demonstrates both Docker AND traditional package management skills

### Network Design
- **Two subnets** simulate real-world network segmentation
- **Firewall rules** follow least-privilege principle
- **Internal communication** for agent→manager traffic (no public exposure)
- **SSH restricted** via configurable CIDR (should be your IP/32)

### Cost Strategy
- Sprint lab approach: deploy → test → destroy
- No persistent resources between sessions
- All state in Terraform — fully reproducible
- ~$0.12/hour = ~$1 per 8-hour session
