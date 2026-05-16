# -----------------------------------------------------------------------------
# VM Definitions — Each VM has a specific role in the SIEM lab
# -----------------------------------------------------------------------------

locals {
  vms = {
    "wazuh-server" = {
      machine_type = var.wazuh_machine_type
      image        = var.ubuntu_image
      subnet       = var.mgmt_subnet_id
      tags         = ["ssh", "wazuh-server"]
      disk_size    = 30
      labels = {
        role    = "wazuh-server"
        os      = "ubuntu"
        project = "siem-lab"
      }
    }

    "agent-ubuntu" = {
      machine_type = var.agent_machine_type
      image        = var.ubuntu_image
      subnet       = var.agents_subnet_id
      tags         = ["ssh", "agent"]
      disk_size    = 20
      labels = {
        role    = "agent"
        os      = "ubuntu"
        project = "siem-lab"
      }
    }

    "agent-rocky" = {
      machine_type = var.agent_machine_type
      image        = var.rocky_image
      subnet       = var.agents_subnet_id
      tags         = ["ssh", "agent"]
      disk_size    = 20
      labels = {
        role    = "agent"
        os      = "rocky"
        project = "siem-lab"
      }
    }

    "agent-debian" = {
      machine_type = var.agent_machine_type
      image        = var.debian_image
      subnet       = var.agents_subnet_id
      tags         = ["ssh", "agent"]
      disk_size    = 20
      labels = {
        role    = "agent"
        os      = "debian"
        project = "siem-lab"
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Compute Instances — Created from the VM definitions map
# -----------------------------------------------------------------------------

resource "google_compute_instance" "vm" {
  for_each = local.vms

  name         = each.key
  machine_type = each.value.machine_type
  zone         = var.zone

  tags   = each.value.tags
  labels = each.value.labels

  boot_disk {
    initialize_params {
      image = each.value.image
      size  = each.value.disk_size
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = each.value.subnet

    # Public IP for SSH access during lab sessions
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_path)}"
  }

  # Allow Terraform to stop the instance to update properties
  allow_stopping_for_update = true

  lifecycle {
    # Prevent accidental destruction without explicit action
    prevent_destroy = false
  }
}
