resource "aws_lambda_function" "main_api" {
  function_name = "MainAPI"

  s3_bucket = var.lambda_bucket_id
  s3_key    = var.main_api_lambda_object_key

  runtime = "nodejs16.x"
  handler = "index.lambdaHandler"

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "main_api" {
  name = "/aws/lambda/${aws_lambda_function.main_api.function_name}"

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
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
