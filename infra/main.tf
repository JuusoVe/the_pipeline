terraform {
  cloud {
    organization = "juusove"

    workspaces {
      name = "the_pipeline"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.29.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "networking" {
  source          = "./modules/networking"
  private_subnets = var.private_subnets
}

module "security-groups" {
  source = "./modules/security-groups"
  region = var.region
  vpc_id = module.networking.vpc_id
  depends_on = [
    module.networking
  ]
}

module "database" {
  source                = "./modules/database"
  vpc_security_group_id = module.security-groups.db_sg_id
  subnet_group_name     = module.networking.subnet_group_name
  availability_zone     = var.availability_zone
  depends_on = [
    module.networking
  ]
}

module "policies" {
  source         = "./modules/policies"
  region         = var.region
  rds_secret_arn = module.database.rds_secret_arn
  depends_on = [
    module.database
  ]
}