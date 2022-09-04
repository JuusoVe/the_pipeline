variable "vpc_security_group_id" {
  description = "ID for the VPC security group to use for connections"
  type        = string
}

variable "availability_zone" {
  default = "eu-central-1a"
}
