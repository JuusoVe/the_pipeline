output "private_subnets" {
  description = "List of private subnets."
  value       = aws_subnet.private
}

output "vpc_id" {
  description = "VPC identifier."
  value       = aws_vpc.main.id
}