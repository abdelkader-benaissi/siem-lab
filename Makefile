# =============================================================================
# SIEM Lab — Makefile
# =============================================================================
# One-command workflow for deploying and managing the SIEM lab on GCP
#
# Usage:
#   make deploy     — Full deployment (Terraform + Ansible)
#   make destroy    — Tear down all infrastructure
#   make plan       — Preview Terraform changes
#   make configure  — Re-run Ansible only (infra already up)
#   make ssh-wazuh  — SSH into the Wazuh server
#   make status     — Show all VM IPs
#   make simulate   — Run attack simulation
# =============================================================================

.PHONY: deploy destroy plan inventory configure ssh-wazuh status simulate validate clean help

PROJECT_DIR   = $(shell pwd)
TERRAFORM_DIR = terraform
ANSIBLE_DIR   = ansible
SCRIPTS_DIR   = scripts

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
	cd $(TERRAFORM_DIR) && terraform init && terraform apply -auto-approve
	@echo ""
	@echo "[2/3] Generating Ansible inventory..."
	bash $(SCRIPTS_DIR)/generate-inventory.sh
	@echo ""
	@echo "[3/3] Configuring VMs with Ansible..."
	@echo "      Waiting 30s for VMs to fully boot..."
	sleep 30
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.ini site.yml
	@echo ""
	@echo "=============================================="
	@echo "  Deployment Complete!"
	@echo "=============================================="
	cd $(TERRAFORM_DIR) && terraform output

destroy: ## 💥 Tear down ALL infrastructure (saves credits!)
	@echo "=============================================="
	@echo "  SIEM Lab — Destroying Infrastructure"
	@echo "=============================================="
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve
	@echo ""
	@echo "  All resources destroyed. Credits preserved! 💰"

plan: ## 📋 Preview infrastructure changes
	cd $(TERRAFORM_DIR) && terraform plan

inventory: ## 📦 Regenerate Ansible inventory from Terraform
	bash $(SCRIPTS_DIR)/generate-inventory.sh

configure: ## ⚙️  Re-run Ansible only (infra must be up)
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.ini site.yml

ssh-wazuh: ## 🔑 SSH into the Wazuh server
	@ssh -i ~/.ssh/gcp_key abdou@$$(cd $(TERRAFORM_DIR) && terraform output -raw wazuh_server_ip)

status: ## 📊 Show all VM IPs and connection info
	@echo "=============================================="
	@echo "  SIEM Lab — Status"
	@echo "=============================================="
	@cd $(TERRAFORM_DIR) && terraform output

simulate: ## ⚔️  Run attack simulation against agent-ubuntu
	@AGENT_IP=$$(cd $(TERRAFORM_DIR) && terraform output -json vm_external_ips | python3 -c "import sys,json; print(json.load(sys.stdin)['agent-ubuntu'])"); \
	bash $(SCRIPTS_DIR)/attack-simulation.sh $$AGENT_IP

dashboard: ## 📊 Create professional SOC dashboard in Wazuh
	@WAZUH_IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw wazuh_server_ip); \
	bash $(SCRIPTS_DIR)/create-dashboard.sh $$WAZUH_IP

validate: ## ✅ Validate Terraform and Ansible syntax
	@echo "Validating Terraform..."
	cd $(TERRAFORM_DIR) && terraform fmt -check -recursive && terraform validate
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
