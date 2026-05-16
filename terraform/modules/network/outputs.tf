output "vpc_name" {
  value       = google_compute_network.vpc.name
  description = "Name of the VPC network"
}

output "vpc_id" {
  value       = google_compute_network.vpc.id
  description = "ID of the VPC network"
}

output "mgmt_subnet_id" {
  value       = google_compute_subnetwork.mgmt.id
  description = "ID of the management subnet"
}

output "agents_subnet_id" {
  value       = google_compute_subnetwork.agents.id
  description = "ID of the agents subnet"
}
