data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = "20.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}


#PRIVATE
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  count             = length(var.private_subnets)
}

resource "aws_db_subnet_group" "main" {
  name = "the_pipeline_database_subnet_group"
  subnet_ids = concat([for subnet in aws_subnet.private : subnet.id],
  [for subnet in aws_subnet.private : subnet.id])

  tags = {
    Name = "DB subnet group"
  }
}



