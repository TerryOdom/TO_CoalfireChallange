# Specifies the provider and version requirements
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configures the AWS provider with the specified region
provider "aws" {
  region = var.aws_region
}
