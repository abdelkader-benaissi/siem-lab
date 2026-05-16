# =============================================================================
# Backend Configuration — Partial config, completed via .tfbackend files
# =============================================================================
# The actual backend settings are in *.tfbackend files (gitignored).
# This keeps sensitive bucket names out of the repo while allowing
# each user to configure their own backend.
#
# Usage:
#   terraform init -backend-config=backend.tfbackend
# =============================================================================

terraform {
  backend "gcs" {}
}
