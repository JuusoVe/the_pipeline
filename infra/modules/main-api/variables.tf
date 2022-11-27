variable "lambda_bucket_id" {
  description = "ID of the bucket that stores lambda code."
  type        = string
}

variable "main_api_lambda_object_key" {
  description = "Key of the S3 object storing code of the main API."
  type        = string
}

variable "gateway_id" {
  description = "ID of the gateway to use."
  type        = string
}

variable "gateway_execution_arn" {
  description = "Excevution ARN of the API gateway."
  type        = string
}

variable "log_group_arn" {
  description = "ARN of the log group for access logging."
  type        = string
}

