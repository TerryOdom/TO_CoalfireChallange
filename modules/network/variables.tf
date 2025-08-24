# ------------------------------------------------------------------
# FILE: modules/networking/variables.tf
# ------------------------------------------------------------------

variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

