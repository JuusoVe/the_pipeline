output "db_username" {
  value = aws_db_instance.main.username
}

output "db_port" {
  value = aws_db_instance.main.port
}

output "db_host" {
  value = aws_db_instance.main.address
}

output "db_instance_id" {
  value = aws_db_instance.main.id
}
