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
  description   = "S3 storage for zip-packaged lambda code."
  source        = "./modules/storage"
  api_file_name = "api.zip"
}



// API GATEWAY
module "api_gateway" {
  source      = "./modules/api-gateway"
  description = "API gateway for lambdas."
}

// THE MAIN API LAMBDA FUNCTION
module "main_api_lambda" {
  source                     = "./modules/main-api"
  lambda_bucket_id           = module.storage.lambda_bucket_id
  main_api_lambda_object_key = module.storage.main_api_lambda_object_key
  gateway_id                 = module.api_gateway.gateway_id
}








resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.main_api_lambda.main_api_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
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
