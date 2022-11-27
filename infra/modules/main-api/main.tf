resource "aws_lambda_function" "main_api" {
  function_name = "MainAPI"

  s3_bucket = var.lambda_bucket_id
  s3_key    = var.main_api_lambda_object_key

  runtime = "nodejs16.x"
  handler = "index.lambdaHandler"

  role = aws_iam_role.lambda_exec.arn

  vpc_config {
    subnet_ids         = var.vpc_intra_subnets
    security_group_ids = var.vpc_security_group_ids
  }

  environment {
    variables = {
      DB_HOST     = var.db_host
      DB_PASSWORD = var.db_password
      DB_USERNAME = var.db_username
    }
  }
}

resource "aws_cloudwatch_log_group" "main_api" {
  name              = "/aws/lambda/${aws_lambda_function.main_api.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "main_api_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      },
    ]
  })
}

// GATEWAY INTEGRATION AND PERMISSIONS
resource "aws_apigatewayv2_stage" "main_api_stage" {
  api_id = var.gateway_id

  name        = "main_api_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = var.log_group_arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "main_api_lambda_integration" {
  api_id             = var.gateway_id
  integration_uri    = aws_lambda_function.main_api.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "main_api" {
  api_id    = var.gateway_id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.main_api_lambda_integration.id}"
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// Allow editing network resources. Required to run inside VPC.
resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.gateway_execution_arn}/*/*"
}
