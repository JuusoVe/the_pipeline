variable "name" {
  description = "Name to use as prefix or suffix for resources."
  default     = "the_pipeline"
}

variable "private_subnets" {
  description = "List of private subnets."
  type        = list(string)
}

variable "availability_zones" {
  description = "a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both private_subnets and public_subnets have to be defined as well"
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}