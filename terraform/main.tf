# =============================================================================
# SIEM Lab — Root Module
# =============================================================================
# Provisions a complete SIEM lab environment on GCP:
#   - Segmented VPC with management and agents subnets
#   - Security-focused firewall rules
#   - Wazuh server (all-in-one) + 3 agent VMs (Ubuntu, Rocky, Debian)
# =============================================================================

locals {
  common_labels = {
    project     = "siem-lab"
    environment = "dev"
    managed_by  = "terraform"
  }
}

# -----------------------------------------------------------------------------
# Network Layer — VPC, subnets, and firewall rules
# -----------------------------------------------------------------------------

module "network" {
  source = "./modules/network"

  vpc_name           = var.vpc_name
  mgmt_subnet_cidr   = var.mgmt_subnet_cidr
  agents_subnet_cidr = var.agents_subnet_cidr
  region             = var.region
  allowed_ssh_cidr   = var.allowed_ssh_cidr
}

# -----------------------------------------------------------------------------
# Compute Layer — VMs for Wazuh server and agents
# -----------------------------------------------------------------------------

module "compute" {
  source = "./modules/compute"

  zone             = var.zone
  ssh_user         = var.ssh_user
  ssh_pub_key_path = var.ssh_pub_key_path

  # Machine types
  wazuh_machine_type = var.wazuh_machine_type
  agent_machine_type = var.agent_machine_type

  # OS images (from data sources)
  ubuntu_image = data.google_compute_image.ubuntu.self_link
  rocky_image  = data.google_compute_image.rocky.self_link
  debian_image = data.google_compute_image.debian.self_link

  # Subnets (from network module)
  mgmt_subnet_id   = module.network.mgmt_subnet_id
  agents_subnet_id = module.network.agents_subnet_id
}
