# -----------------------------------------------------------------------------
# VM External IPs — for SSH and dashboard access
# -----------------------------------------------------------------------------

output "vm_external_ips" {
  value = {
    for name, vm in google_compute_instance.vm :
    name => vm.network_interface[0].access_config[0].nat_ip
  }
  description = "Map of VM names to their external (public) IPs"
}

# -----------------------------------------------------------------------------
# VM Internal IPs — for inter-VM communication
# -----------------------------------------------------------------------------

output "vm_internal_ips" {
  value = {
    for name, vm in google_compute_instance.vm :
    name => vm.network_interface[0].network_ip
  }
  description = "Map of VM names to their internal (private) IPs"
}

# -----------------------------------------------------------------------------
# Individual outputs for convenience
# -----------------------------------------------------------------------------

output "wazuh_server_external_ip" {
  value       = google_compute_instance.vm["wazuh-server"].network_interface[0].access_config[0].nat_ip
  description = "External IP of the Wazuh server"
}

output "wazuh_server_internal_ip" {
  value       = google_compute_instance.vm["wazuh-server"].network_interface[0].network_ip
  description = "Internal IP of the Wazuh server (used by agents)"
}
