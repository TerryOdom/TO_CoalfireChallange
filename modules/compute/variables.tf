# ------------------------------------------------------------------
# FILE: modules/compute/variables.tf
# ------------------------------------------------------------------

variable "project_name" {
  type = string
}

variable "key_name" {
  type = string
}

variable "mgmt_subnet_id" {
  type = string
}

variable "app_subnet_ids" {
  type = list(string)
}

variable "mgmt_security_group_id" {
  type = string
}

variable "app_security_group_id" {
  type = string
}
