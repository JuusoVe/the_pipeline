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

# Attach the above policy resouce to a role
resource "aws_iam_role_policy_attachment" "rds_proxy_iam_attach" {
  policy_arn = aws_iam_policy.rds_proxy_iam_policy.arn
  role       = aws_iam_role.rds_proxy_iam_role.name
}

resource "aws_db_proxy" "main_db_proxy" {
  name                   = "main"
  debug_logging          = true
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 60
  require_tls            = true
  role_arn               = aws_iam_role.rds_proxy_iam_role.arn
  vpc_security_group_ids = var.vpc_security_group_ids
  vpc_subnet_ids         = var.vpc_intra_subnets

  auth {
    auth_scheme = "SECRETS"
    description = "RDS Secret"
    iam_auth    = "DISABLED"
    secret_arn  = var.rds_secret_arn
  }
}
