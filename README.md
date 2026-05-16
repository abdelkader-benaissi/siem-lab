# 🛡️ SIEM Lab on GCP — Infrastructure as Code

> Fully automated SIEM lab environment using **Terraform** + **Ansible** + **Docker** + **Wazuh** on Google Cloud Platform.  
> Deploy a complete Security Operations Center simulation with one command. Tear it down just as fast.

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                    GCP Project (europe-west1)                    │
│                                                                  │
│  ┌─────────────── VPC: siem-lab-vpc (10.10.0.0/16) ───────────┐ │
│  │                                                              │ │
│  │  ┌─── mgmt-subnet (10.10.1.0/24) ───┐                      │ │
│  │  │                                    │                      │ │
│  │  │  🛡️ wazuh-server                  │                      │ │
│  │  │  e2-standard-2 (8GB, 2 vCPU)      │                      │ │
│  │  │  Ubuntu 22.04 + Docker            │                      │ │
│  │  │  Wazuh Manager + Indexer +        │                      │ │
│  │  │  Dashboard (All-in-One)           │                      │ │
│  │  │                                    │                      │ │
│  │  └─────────────▲──────────────────────┘                      │ │
│  │                │ 1514/1515                                   │ │
│  │  ┌─────────────┴─── agents-subnet (10.10.2.0/24) ────────┐  │ │
│  │  │                                                         │  │ │
│  │  │  🐧 agent-ubuntu     🎩 agent-rocky     🐧 agent-debian│  │ │
│  │  │  e2-small (2GB)      e2-small (2GB)     e2-small (2GB) │  │ │
│  │  │  Ubuntu 22.04        Rocky Linux 9      Debian 12      │  │ │
│  │  │  Docker + Agent      Docker + Agent     Docker + Agent │  │ │
│  │  │                                                         │  │ │
│  │  └─────────────────────────────────────────────────────────┘  │ │
│  └──────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

## ✨ Features

- **Infrastructure as Code** — Entire environment defined in Terraform with reusable modules
- **Configuration Management** — Ansible roles for Docker, SSH hardening, Wazuh server & agents
- **Multi-OS Support** — Agents deployed on Ubuntu, Rocky Linux, and Debian
- **Network Segmentation** — Separate subnets for management and monitored hosts
- **Security-First Firewall** — Least-privilege rules (SSH restricted, internal-only agent communication)
- **One-Command Workflow** — `make deploy` / `make destroy` for fast lab sessions
- **Attack Simulation** — Built-in scripts to generate real security alerts
- **Cost Optimized** — ~$1 per 8-hour session on GCP free trial credits

## 📋 Prerequisites

- [Terraform](https://www.terraform.io/) >= 1.5.0
- [Ansible](https://www.ansible.com/) >= 2.14
- [Google Cloud SDK](https://cloud.google.com/sdk) (authenticated with `gcloud auth login`)
- GCP project with Compute Engine API enabled
- SSH key pair at `~/.ssh/gcp_key` and `~/.ssh/gcp_key.pub`

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/abdelkader-benaissi/siem-lab.git
cd siem-lab

# 2. Configure your settings
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with your GCP project ID

# 3. Deploy everything (Terraform + Ansible + Wazuh)
make deploy

# 4. Access the Wazuh Dashboard
make status    # Get the dashboard URL
# Open https://<wazuh-server-ip> in your browser
# Login: admin / SecretPassword

# 5. Run attack simulation to generate alerts
make simulate

# 6. IMPORTANT: Destroy when done to save credits!
make destroy
```

## 📂 Project Structure

```
siem-lab/
├── Makefile                          # One-command workflow
├── terraform/                        # Infrastructure provisioning
│   ├── main.tf                       # Root module
│   ├── variables.tf / outputs.tf     # Variables and outputs
│   └── modules/
│       ├── network/                  # VPC, subnets, firewall rules
│       └── compute/                  # VM instances (4 VMs)
├── ansible/                          # Configuration management
│   ├── site.yml                      # Master playbook
│   ├── group_vars/                   # Per-group variables
│   └── roles/
│       ├── common/                   # Docker, SSH hardening, packages
│       ├── wazuh_server/             # Wazuh All-in-One deployment
│       └── wazuh_agent/              # Agent install & enrollment
├── scripts/
│   ├── generate-inventory.sh         # Terraform → Ansible bridge
│   └── attack-simulation.sh          # Generate security events
└── docs/
    └── architecture.md
```

## 💰 Cost Estimate

| Resource | Type | Cost/hour |
|:---|:---|:---|
| Wazuh Server | e2-standard-2 (8GB, 2 vCPU) | ~$0.067 |
| 3× Agent VMs | e2-small (2GB, 1 vCPU) | ~$0.051 |
| Storage | 90 GB pd-standard | ~$0.003 |
| **Total** | | **~$0.12/hr** |

**8-hour lab session ≈ $1** → Your $300 GCP credit supports **300+ sessions**.

> ⚠️ **Always run `make destroy` when done!**

## 🛠️ Available Commands

```bash
make deploy      # 🚀 Full deploy: Terraform + Ansible + Wazuh
make destroy     # 💥 Tear down everything (save credits!)
make plan        # 📋 Preview infrastructure changes
make configure   # ⚙️  Re-run Ansible only
make ssh-wazuh   # 🔑 SSH into Wazuh server
make status      # 📊 Show VM IPs and connection info
make simulate    # ⚔️  Run attack simulation
make validate    # ✅ Validate Terraform & Ansible syntax
```

## 🔐 Security Features

- **Network Segmentation**: Management and agent VMs on separate subnets
- **Restrictive Firewall**: SSH access limited (configurable CIDR), internal-only agent communication
- **SSH Hardening**: Root login disabled, password auth disabled, key-only access
- **Wazuh Monitoring**: File Integrity Monitoring, rootcheck, SCA, log analysis
- **TLS Encryption**: All Wazuh component communication encrypted

## 🧰 Tech Stack

| Layer | Tools |
|:---|:---|
| Infrastructure | Terraform, GCP Compute Engine |
| Configuration | Ansible (roles-based) |
| Containerization | Docker, Docker Compose |
| SIEM Platform | Wazuh 4.14 (Manager + Indexer + Dashboard) |
| OS | Ubuntu 22.04, Rocky Linux 9, Debian 12 |
| CI/CD | GitHub Actions (validate on push) |

## 📖 What I Learned

- Designing segmented cloud networks with Terraform modules
- Multi-OS configuration management with Ansible roles
- Deploying and managing Wazuh SIEM in a Docker environment
- Writing security-focused firewall rules (least privilege)
- Building reproducible, ephemeral lab environments for cost efficiency
- Bridging Terraform and Ansible with automated inventory generation

## 📝 License

This project is for educational purposes. Built by [Abdelkader Benaissi](https://abdelkader-benaissi.github.io/).
