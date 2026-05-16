variable "zone" {
  type        = string
  description = "GCP zone for compute instances"
}

variable "ssh_user" {
  type        = string
  description = "SSH username for VM access"
}

variable "ssh_pub_key_path" {
  type        = string
  description = "Path to the SSH public key file"
}

# -----------------------------------------------------------------------------
# Machine Types
# -----------------------------------------------------------------------------

variable "wazuh_machine_type" {
  type        = string
  description = "Machine type for the Wazuh server"
}

variable "agent_machine_type" {
  type        = string
  description = "Machine type for agent VMs"
}

# -----------------------------------------------------------------------------
# OS Images (passed from data sources in root module)
# -----------------------------------------------------------------------------

variable "ubuntu_image" {
  type        = string
  description = "Self-link of the Ubuntu image"
}

variable "rocky_image" {
  type        = string
  description = "Self-link of the Rocky Linux image"
}

variable "debian_image" {
  type        = string
  description = "Self-link of the Debian image"
}

# -----------------------------------------------------------------------------
# Subnets (passed from network module)
# -----------------------------------------------------------------------------

variable "mgmt_subnet_id" {
  type        = string
  description = "ID of the management subnet"
}

variable "agents_subnet_id" {
  type        = string
  description = "ID of the agents subnet"
}
