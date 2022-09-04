output "rds_secret_arn" {
  description = "DB secret identifier."
  value       = aws_secretsmanager_secret_version.rds_secret_version.arn
}