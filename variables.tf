# ------------------------------------------------------------------
# FILE: variables.tf (Root Module)
# ------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "A name for the project to prefix resources."
  type        = string
  default     = "coalfire-challenge"
}

variable "my_ip" {
  description = "Your local IP address to allow SSH access to the management host."
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "The name of your existing AWS EC2 Key Pair for SSH access."
  type        = string
}

