# Remote state in GCS — configure with your own bucket
# terraform {
#   backend "gcs" {
#     bucket = "your-tf-state-bucket"
#     prefix = "siem-lab"
#   }
# }

# Local state (default for lab usage)
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
