# -----------------------------------------------------------------------------
# OS Images — Latest LTS versions for each distribution
# -----------------------------------------------------------------------------

data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
}

data "google_compute_image" "rocky" {
  family  = "rocky-linux-9"
  project = "rocky-linux-cloud"
}
