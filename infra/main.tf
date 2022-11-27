// GENERAL
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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  api_file_name = "api.zip"
}

// STORAGE FOR LAMBDAS
module "storage" {
  source        = "./modules/storage"
  api_file_name = local.api_file_name
}

// API GATEWAY
resource "aws_apigatewayv2_api" "gateway" {
  name          = "main_api_gw"
  protocol_type = "HTTP"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.gateway.name}"
  retention_in_days = 30
}


// PRIVATE NETWORKING FOR DB AND CONNECTIONS TO IT
module "networking" {
  source          = "./modules/networking"
  private_subnets = var.private_subnets
}

module "security_groups" {
  source = "./modules/security-groups"
  region = var.region
  vpc_id = module.networking.vpc_id
  depends_on = [
    module.networking
  ]
}

// DATABASE AND REQUIRED SECRETS
resource "random_password" "password" {
  length  = 24
  special = false
}

// THE MAIN DATABASE
module "database" {
  source                = "./modules/database"
  vpc_security_group_id = module.security_groups.db_sg_id
  availability_zone     = var.availability_zone
  subnet_group_name     = module.networking.subnet_group_name
  db_password           = random_password.password.result
  depends_on = [
    module.networking,
    module.security_groups
  ]
}

// SECRET TO ACCESS THE DB
resource "aws_secretsmanager_secret" "rds_secret" {
  name_prefix             = "rds-proxy-secret"
  recovery_window_in_days = 0 # Allow permanent deletion without delay
  description             = "Secret for RDS Proxy"
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    "username"             = module.database.db_username
    "password"             = random_password.password.result
    "engine"               = "postgres"
    "host"                 = module.database.db_host
    "port"                 = module.database.db_port
    "dbInstanceIdentifier" = module.database.db_instance_id
  })
}

// DB PROXY FOR LAMBDA
module "database_proxy" {
  source                 = "./modules/database-proxy"
  region                 = var.region
  rds_secret_arn         = aws_secretsmanager_secret.rds_secret.arn
  vpc_intra_subnets      = [for subnet in module.networking.private_subnets : subnet.id]
  vpc_security_group_ids = [module.security_groups.db_sg_id]
  depends_on = [
    module.networking,
    module.security_groups
  ]
}


// THE MAIN API LAMBDA FUNCTION
module "main_api_lambda" {
  source                     = "./modules/main-api"
  lambda_bucket_id           = module.storage.lambda_bucket_id
  main_api_lambda_object_key = module.storage.main_api_lambda_object_key
  gateway_id                 = aws_apigatewayv2_api.gateway.id
  gateway_execution_arn      = aws_apigatewayv2_api.gateway.execution_arn
  log_group_arn              = aws_cloudwatch_log_group.api_gw.arn
  vpc_intra_subnets          = [module.networking.private_subnets[0].id]
  vpc_security_group_ids     = [module.security_groups.db_sg_id]
  db_host                    = module.database_proxy.db_host
  db_password                = random_password.password.result
  db_username                = module.database.db_username
  depends_on = [
    module.storage,
    aws_apigatewayv2_api.gateway,
    module.database
  ]
}
