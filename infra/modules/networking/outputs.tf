output "subnet_group_name" {
  description = "Subnet group name."
  value       = var.database_subnet_group_name
}

output "private_subnets" {
  description = "List of private subnets."
  value       = aws_subnet.private
}

output "vpc_id" {
  description = "VPC identifier."
  value       = aws_vpc.main.id
}