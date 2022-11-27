output "function_name" {
  description = "Name of the Lambda function."
  value       = module.main_api_lambda.main_api_function_name
}

output "base_url" {
  description = "Base URL for API Gateway stage."
  value       = aws_apigatewayv2_stage.lambda.invoke_url
}
