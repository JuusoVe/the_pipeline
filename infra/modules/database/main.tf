resource "aws_db_instance" "main" {
  identifier             = "main"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.2"
  username               = "postgres"
  password               = var.db_password
  db_subnet_group_name   = var.subnet_group_name
  vpc_security_group_ids = [var.vpc_security_group_id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  availability_zone      = var.availability_zone
}
