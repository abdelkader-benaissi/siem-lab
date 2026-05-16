# -----------------------------------------------------------------------------
# Project Configuration
# -----------------------------------------------------------------------------

variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region for resources"
}

variable "zone" {
  type        = string
  description = "GCP zone for compute instances"
}

# -----------------------------------------------------------------------------
# SSH Configuration
# -----------------------------------------------------------------------------

variable "ssh_user" {
  type        = string
  description = "SSH username for VM access"
  default     = "abdou"
}

variable "ssh_pub_key_path" {
  type        = string
  description = "Path to the SSH public key file"
  default     = "~/.ssh/gcp_key.pub"
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "vpc_name" {
  type        = string
  description = "Name of the VPC network"
  default     = "siem-lab-vpc"
}

variable "mgmt_subnet_cidr" {
  type        = string
  description = "CIDR range for management subnet (Wazuh server)"
  default     = "10.10.1.0/24"
}

variable "agents_subnet_cidr" {
  type        = string
  description = "CIDR range for agents subnet (monitored VMs)"
  default     = "10.10.2.0/24"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR range allowed to SSH into VMs (your public IP/32). Use 0.0.0.0/0 only for testing."
  default     = "0.0.0.0/0"
}

# -----------------------------------------------------------------------------
# Compute Configuration
# -----------------------------------------------------------------------------

variable "wazuh_machine_type" {
  type        = string
  description = "Machine type for the Wazuh server (needs at least 8GB RAM)"
  default     = "e2-standard-2"
}

variable "agent_machine_type" {
  type        = string
  description = "Machine type for agent VMs"
  default     = "e2-small"
}
