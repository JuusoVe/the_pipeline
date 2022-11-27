output "main_api_invoke_arn" {
  description = "Invoke arn of the main API lambda."
  value       = aws_lambda_function.main_api.invoke_arn
}

output "main_api_function_name" {
  description = "Function name of trhe main API lambda"
  value       = aws_lambda_function.main_api.function_name
}
