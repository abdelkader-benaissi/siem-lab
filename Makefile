# =============================================================================
# SIEM Lab — Makefile
# =============================================================================
# One-command workflow for deploying and managing the SIEM lab on GCP
#
# Usage:
#   make setup       — First-time Terraform init
#   make deploy      — Full deployment (Terraform + Ansible)
#   make destroy     — Tear down all infrastructure
#   make simulate    — Run attack simulation (single agent)
#   make simulate-all — Run attack simulation (all agents)
#   make help        — Show all commands
# =============================================================================

.PHONY: deploy destroy setup plan inventory configure ssh-wazuh status \
        simulate simulate-all dashboard validate clean help

PROJECT_DIR   = $(shell pwd)
TERRAFORM_DIR = terraform
ANSIBLE_DIR   = ansible
SCRIPTS_DIR   = scripts
TF_BACKEND    = $(TERRAFORM_DIR)/backend.tfbackend

# Configurable defaults (override via environment or command line)
SSH_KEY  ?= $(HOME)/.ssh/gcp_key
SSH_USER ?= $(shell cd $(TERRAFORM_DIR) && terraform output -raw ssh_user 2>/dev/null || echo ubuntu)

# Terraform init command (auto-detects backend config)
TF_INIT = terraform init $(if $(wildcard $(TF_BACKEND)),-backend-config=$(PROJECT_DIR)/$(TF_BACKEND),)

export ANSIBLE_CONFIG = $(PROJECT_DIR)/$(ANSIBLE_DIR)/ansible.cfg

# Default target
.DEFAULT_GOAL := help

# =============================================================================
# Main Targets
# =============================================================================

deploy: ## 🚀 Full deploy: provision infra + configure VMs + deploy Wazuh
	@echo "=============================================="
	@echo "  SIEM Lab — Full Deployment"
	@echo "=============================================="
	@echo ""
	@echo "[1/3] Provisioning infrastructure with Terraform..."
	cd $(TERRAFORM_DIR) && $(TF_INIT) && terraform apply -auto-approve
	@echo ""
	@echo "[2/3] Generating Ansible inventory..."
	bash $(SCRIPTS_DIR)/generate-inventory.sh
	@echo ""
	@echo "[3/3] Configuring VMs with Ansible..."
	@echo "      Waiting for VMs to accept SSH connections..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.ini site.yml
	@echo ""
	@echo "=============================================="
	@echo "  Deployment Complete!"
	@echo "=============================================="
	cd $(TERRAFORM_DIR) && terraform output

destroy: ## 💥 Tear down ALL infrastructure (confirms first)
	@echo "=============================================="
	@echo "  SIEM Lab — Destroying Infrastructure"
	@echo "=============================================="
	@echo ""
	@echo "  This will destroy ALL VMs, networks, and firewall rules."
	@read -p "  ⚠️  Are you sure? Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ] || (echo "  Aborted." && exit 1)
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve
	@echo ""
	@echo "  All resources destroyed. Credits preserved! 💰"

setup: ## 🔧 First-time setup (init Terraform backend)
	@echo "Initializing Terraform with backend config..."
	cd $(TERRAFORM_DIR) && $(TF_INIT) -reconfigure
	@echo "✅ Terraform initialized. Run 'make deploy' to start."

plan: ## 📋 Preview infrastructure changes
	cd $(TERRAFORM_DIR) && terraform plan

inventory: ## 📦 Regenerate Ansible inventory from Terraform
	bash $(SCRIPTS_DIR)/generate-inventory.sh

configure: ## ⚙️  Re-run Ansible only (infra must be up)
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.ini site.yml

ssh-wazuh: ## 🔑 SSH into the Wazuh server
	@ssh -i $(SSH_KEY) $(SSH_USER)@$$(cd $(TERRAFORM_DIR) && terraform output -raw wazuh_server_ip)

status: ## 📊 Show all VM IPs and connection info
	@echo "=============================================="
	@echo "  SIEM Lab — Status"
	@echo "=============================================="
	@cd $(TERRAFORM_DIR) && terraform output

simulate: ## ⚔️  Run attack simulation against agent-ubuntu
	@AGENT_IP=$$(cd $(TERRAFORM_DIR) && terraform output -json vm_external_ips | python3 -c "import sys,json; print(json.load(sys.stdin)['agent-ubuntu'])"); \
	bash $(SCRIPTS_DIR)/attack-simulation.sh $$AGENT_IP

simulate-all: ## ⚔️  Run attack simulation against ALL agents
	@echo "=============================================="
	@echo "  Simulating attacks on ALL agents..."
	@echo "=============================================="
	@for agent in agent-ubuntu agent-debian agent-rocky; do \
		AGENT_IP=$$(cd $(TERRAFORM_DIR) && terraform output -json vm_external_ips 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('$$agent',''))" 2>/dev/null); \
		if [ -n "$$AGENT_IP" ]; then \
			echo ""; \
			echo ">>> Targeting: $$agent ($$AGENT_IP)"; \
			bash $(SCRIPTS_DIR)/attack-simulation.sh $$AGENT_IP || true; \
		fi; \
	done

dashboard: ## 📊 Create professional SOC dashboard in Wazuh
	@WAZUH_IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw wazuh_server_ip); \
	bash $(SCRIPTS_DIR)/create-dashboard.sh $$WAZUH_IP

validate: ## ✅ Validate Terraform and Ansible syntax
	@echo "Validating Terraform..."
	cd $(TERRAFORM_DIR) && $(TF_INIT) && terraform fmt -check -recursive && terraform validate
	@echo ""
	@echo "Validating Ansible..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.ini site.yml --syntax-check
	@echo ""
	@echo "All validations passed! ✅"

clean: ## 🧹 Remove generated files (inventory, Terraform cache)
	rm -f $(ANSIBLE_DIR)/inventory/hosts.ini
	rm -rf $(TERRAFORM_DIR)/.terraform
	rm -f $(TERRAFORM_DIR)/.terraform.lock.hcl
	@echo "Cleaned generated files."

# =============================================================================
# Help
# =============================================================================

help: ## 📖 Show this help message
	@echo "=============================================="
	@echo "  SIEM Lab — Available Commands"
	@echo "=============================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
