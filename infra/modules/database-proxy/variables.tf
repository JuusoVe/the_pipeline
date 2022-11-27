variable "region" {}

variable "rds_secret_arn" {
  description = "ARN of the secret containing DB connection credentials"
  type        = string
}

variable "vpc_intra_subnets" {
  description = "Private subnets CIDR list."
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "Security group ids with access to the lambda."
  type        = list(string)
}

