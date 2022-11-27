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

// THE MAIN API LAMBDA FUNCTION
module "main_api_lambda" {
  source                     = "./modules/main-api"
  lambda_bucket_id           = module.storage.lambda_bucket_id
  main_api_lambda_object_key = module.storage.main_api_lambda_object_key
  gateway_id                 = aws_apigatewayv2_api.gateway.id
  gateway_execution_arn      = aws_apigatewayv2_api.gateway.execution_arn
  log_group_arn              = aws_cloudwatch_log_group.api_gw.arn
  depends_on = [
    module.storage,
    aws_apigatewayv2_api.gateway
  ]
}










# module "networking" {
#   source          = "./modules/networking"
#   private_subnets = var.private_subnets
# }

# module "security-groups" {
#   source = "./modules/security-groups"
#   region = var.region
#   vpc_id = module.networking.vpc_id
#   depends_on = [
#     module.networking
#   ]
# }

# module "database" {
#   source                = "./modules/database"
#   vpc_security_group_id = module.security-groups.db_sg_id
#   availability_zone     = var.availability_zone
#   subnet_group_name     = module.networking.subnet_group_name
#   depends_on = [
#     module.networking
#   ]
# }

# module "policies" {
#   source         = "./modules/policies"
#   region         = var.region
#   rds_secret_arn = module.database.rds_secret_arn
#   depends_on = [
#     module.database
#   ]
# }
