output "lambda_bucket_id" {
  description = "ID of the S3 bucket for storing lambda functions."
  value       = aws_s3_bucket.lambda_bucket.id
}

output "main_api_lambda_object_key" {
  description = "Object key of the S3 object containing the main API code."
  value       = aws_s3_object.lambda_main_api.key
}
