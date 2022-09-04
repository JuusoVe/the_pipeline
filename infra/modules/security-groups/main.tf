
# SECURITY GROUPS

# Allow connection from the VPC to Lambda
resource "aws_security_group" "sg_lambda" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow connections from the Lambda to SQL proxy
resource "aws_security_group" "sg_rds_proxy" {
  vpc_id = var.vpc_id

  ingress {
    description     = "PostgreSQL TLS from sg_lambda"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_lambda.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow connections from the SQL Proxy to the DB
resource "aws_security_group" "sg_rds" {
  vpc_id = var.vpc_id

  ingress {
    description     = "PostgreSQL TLS from sg_rds_proxy"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_rds_proxy.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# POLICIES

# Define the permission to assume a IAM Role as a data source for TF




