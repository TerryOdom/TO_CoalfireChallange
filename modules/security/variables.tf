# ------------------------------------------------------------------
# FILE: modules/security/variables.tf
# ------------------------------------------------------------------

variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "my_ip" {
  description = "Your local IP for SSH access."
  type        = string
}

