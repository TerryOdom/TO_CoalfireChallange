# Defines the AWS region where resources will be created
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

# Defines the primary CIDR block for the VPC
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.1.0.0/16"
}

# Defines the CIDR block for the public management subnet
variable "management_subnet_cidr" {
  description = "The CIDR block for the management subnet."
  type        = string
  default     = "10.1.1.0/24"
}

# Defines the CIDR block for the private application subnet
variable "application_subnet_cidr" {
  description = "The CIDR block for the application subnet."
  type        = string
  default     = "10.1.2.0/24"
}

# Defines the CIDR block for the private backend subnet
variable "backend_subnet_cidr" {
  description = "The CIDR block for the backend subnet."
  type        = string
  default     = "10.1.3.0/24"
}
