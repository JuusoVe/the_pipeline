variable "vpc_id" {
  type = string
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "rds_secret_arn" {
  
}

variable "region" {
  type = string
}