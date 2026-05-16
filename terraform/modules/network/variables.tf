variable "vpc_name" {
  type        = string
  description = "Name of the VPC network"
}

variable "mgmt_subnet_cidr" {
  type        = string
  description = "CIDR range for the management subnet"
}

variable "agents_subnet_cidr" {
  type        = string
  description = "CIDR range for the agents subnet"
}

variable "region" {
  type        = string
  description = "GCP region for subnets"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR range allowed to SSH into VMs"
}
