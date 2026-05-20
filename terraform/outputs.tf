# =============================================================================
# Outputs — Quick access to IPs and connection info
# =============================================================================

# -----------------------------------------------------------------------------
# Wazuh Server
# -----------------------------------------------------------------------------

output "wazuh_dashboard_url" {
  value       = "https://${module.compute.wazuh_server_external_ip}"
  description = "URL to access the Wazuh Dashboard (see ansible/group_vars/wazuh_server.yml for credentials)"
}

output "wazuh_server_ip" {
  value       = module.compute.wazuh_server_external_ip
  description = "External IP of the Wazuh server"
}

output "wazuh_server_internal_ip" {
  value       = module.compute.wazuh_server_internal_ip
  description = "Internal IP of the Wazuh server (used by agents for enrollment)"
}

# -----------------------------------------------------------------------------
# All VMs
# -----------------------------------------------------------------------------

output "vm_external_ips" {
  value       = module.compute.vm_external_ips
  description = "Map of all VM names to their external IPs"
}

output "vm_internal_ips" {
  value       = module.compute.vm_internal_ips
  description = "Map of all VM names to their internal IPs"
}

# -----------------------------------------------------------------------------
# Quick SSH Commands
# -----------------------------------------------------------------------------

output "ssh_user" {
  value       = var.ssh_user
  description = "SSH username configured for all VMs"
}

output "ssh_commands" {
  value = {
    for name, ip in module.compute.vm_external_ips :
    name => "ssh -i ~/.ssh/gcp_key ${var.ssh_user}@${ip}"
  }
  description = "Ready-to-use SSH commands for each VM"
}
