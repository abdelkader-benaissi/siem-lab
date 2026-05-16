# -----------------------------------------------------------------------------
# VPC Network — Custom mode (no auto-created subnets)
# -----------------------------------------------------------------------------

resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  description             = "SIEM Lab VPC - isolated network for Wazuh deployment"
}

# -----------------------------------------------------------------------------
# Subnets — Separated by role for network segmentation
# -----------------------------------------------------------------------------

resource "google_compute_subnetwork" "mgmt" {
  name          = "${var.vpc_name}-mgmt"
  ip_cidr_range = var.mgmt_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  description   = "Management subnet — Wazuh server"
}

resource "google_compute_subnetwork" "agents" {
  name          = "${var.vpc_name}-agents"
  ip_cidr_range = var.agents_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  description   = "Agents subnet — monitored VMs"
}
