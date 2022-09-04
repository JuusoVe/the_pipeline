variable "vpc_security_group_id" {
  description = "ID for the VPC security group to use for connections"
  type        = string
}

variable "availability_zone" {
  default = "eu-central-1a"
}

variable "subnet_group_name" {
  type        = string
  description = "The name of the subnetgroup that the DB will exist in."
}