# ------------------------------------------------------------------
# FILE: main.tf (Root Module)
# ------------------------------------------------------------------
# This file is the main entrypoint for the Terraform configuration.
# It defines the providers and orchestrates the calls to the various
# modules responsible for creating the infrastructure.
# ------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Module Calls ---
# We create the infrastructure in a logical order:
# 1. network: The foundation of our environment.
# 2. Security: Defines the firewall rules before creating instances.
# 3. Compute: Deploys the EC2 instances and ASG.
# 4. Load Balancer: Deploys the ALB and connects it to the compute resources.
# ------------------------------------------------------------------

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  vpc_cidr     = "10.1.0.0/16"
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  vpc_id       = module.network.vpc_id
  my_ip        = var.my_ip
}

module "compute" {
  source = "./modules/compute"

  project_name          = var.project_name
  key_name              = var.key_name
  mgmt_subnet_id        = module.network.mgmt_subnet_id
  app_subnet_ids        = module.network.app_subnet_ids
  mgmt_security_group_id = module.security.mgmt_sg_id
  app_security_group_id  = module.security.app_sg_id
}

module "load_balancer" {
  source = "./modules/load_balancer"

  project_name    = var.project_name
  vpc_id          = module.network.vpc_id
  public_subnet_ids = [module.network.mgmt_subnet_id] # Using mgmt subnet as public
  alb_sg_id       = module.security.alb_sg_id
  asg_name        = module.compute.asg_name
}
