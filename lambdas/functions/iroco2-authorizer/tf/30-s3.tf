resource "aws_s3_bucket" "lambda_s3_bucket" {
  bucket = "lambda-${var.project_name}-${var.namespace}"
}