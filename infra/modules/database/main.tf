resource "random_password" "password" {
  length  = 24
  special = false
}

resource "aws_db_instance" "main" {
  identifier             = "main"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.2"
  username               = "postgres"
  password               = random_password.password
  db_subnet_group_name   = var.subnet_group_name
  vpc_security_group_ids = [var.vpc_security_group_id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  availability_zone      = var.availability_zone
}

resource "aws_secretsmanager_secret" "rds_secret" {
  name_prefix             = "rds-proxy-secret"
  recovery_window_in_days = 0 # Allow permanent deletion without delay
  description             = "Secret for RDS Proxy"
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    "username"             = aws_db_instance.main.username
    "password"             = random_password.password
    "engine"               = "postgres"
    "host"                 = aws_db_instance.main.address
    "port"                 = 5432
    "dbInstanceIdentifier" = aws_db_instance.main.id
  })
}