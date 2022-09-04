variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "private_subnets" {
  description = "List of private subnets."
  type        = set(string)
  default     = ["20.10.1.0/24", "20.10.2.0/24", "20.10.3.0/24"]
}

variable "availability_zone" {
  default = "eu-central-1a"
}