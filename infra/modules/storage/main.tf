locals {
  api_file_path = "./${var.api_file_name}"
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "the-pipeline-functions"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

resource "aws_s3_object" "lambda_main_api" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = var.api_file_name
  source = local.api_file_path

  etag = filemd5(local.api_file_path)
}
