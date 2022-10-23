output "db_password" {
  sensitive = true
  value     = random_password.password.result
}