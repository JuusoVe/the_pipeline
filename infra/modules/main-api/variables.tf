variable "lambda_bucket_id" {
  type        = string
  description = "ID of the bucket that stores lambda code."
}

variable "main_api_lambda_object_key" {
  type        = string
  description = "Key of the S3 object storing code of the main API."
}
