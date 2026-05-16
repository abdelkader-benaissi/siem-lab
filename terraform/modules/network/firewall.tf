# -----------------------------------------------------------------------------
# Firewall Rules — Defense-in-depth approach
# -----------------------------------------------------------------------------

# SSH access — restricted to deployer's IP
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.vpc_name}-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.allowed_ssh_cidr]
  target_tags   = ["ssh"]
  description   = "Allow SSH from deployer IP only"
}

# Wazuh Dashboard — HTTPS access for the web UI
resource "google_compute_firewall" "allow_wazuh_dashboard" {
  name    = "${var.vpc_name}-allow-wazuh-dashboard"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = [var.allowed_ssh_cidr]
  target_tags   = ["wazuh-server"]
  description   = "Allow HTTPS access to Wazuh Dashboard"
}

# Wazuh Agent communication — agents → manager (internal only)
resource "google_compute_firewall" "allow_wazuh_agents" {
  name    = "${var.vpc_name}-allow-wazuh-agents"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["1514", "1515"]
  }

  source_ranges = [var.agents_subnet_cidr]
  target_tags   = ["wazuh-server"]
  description   = "Allow Wazuh agent registration (1515) and event data (1514) from agents subnet"
}

# Internal ICMP — for network diagnostics between all VMs
resource "google_compute_firewall" "allow_internal_icmp" {
  name    = "${var.vpc_name}-allow-internal-icmp"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.10.0.0/16"]
  description   = "Allow ICMP (ping) within the VPC for diagnostics"
}
