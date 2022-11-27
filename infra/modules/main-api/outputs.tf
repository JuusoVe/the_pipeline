output "main_api_invoke_arn" {
  description = "Invoke arn of the main API lambda."
  value       = aws_lambda_function.main_api.invoke_arn
}

output "main_api_function_name" {
  description = "Function name of trhe main API lambda"
  value       = aws_lambda_function.main_api.function_name
}

output "main_api_stage_invoke_arn" {
  description = "Invoke url of thee stage to access the main API."
  value       = aws_apigatewayv2_stage.main_api_stage.invoke_url
}
