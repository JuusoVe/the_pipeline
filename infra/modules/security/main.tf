
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
data "aws_iam_policy_document" "assume_role" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

# Define the permissions we want to give the SQL Proxy as a data source for TF
data "aws_iam_policy_document" "rds_proxy_policy_document" {
  statement {
    sid = "AllowProxyToGetDbCredsFromSecretsManager"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      var.rds_secret_arn
    ]
  }

  statement {
    sid = "AllowProxyToDecryptDbCredsFromSecretsManager"

    actions = [
      "kms:Decrypt"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      values   = ["secretsmanager.${var.region}.amazonaws.com"]
      variable = "kms:ViaService"
    }
  }
}

# Create the actual policy resource from the above permissions
resource "aws_iam_policy" "rds_proxy_iam_policy" {
  name   = "rds-proxy-policy"
  policy = data.aws_iam_policy_document.rds_proxy_policy_document.json
}

# Create a IAM role that uses the policy from above to assume a role
resource "aws_iam_role" "rds_proxy_iam_role" {
  name               = "rds-proxy-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach the above policy resrouce to a role
resource "aws_iam_role_policy_attachment" "rds_proxy_iam_attach" {
  policy_arn = aws_iam_policy.rds_proxy_iam_policy.arn
  role       = aws_iam_role.rds_proxy_iam_role.name
}



