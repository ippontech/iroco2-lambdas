resource "aws_s3_bucket" "cur_s3_bucket" {
  bucket = "${var.project_name}-${var.namespace}-${var.environment}"
}

resource "aws_s3_bucket" "lambda_s3_bucket" {
  bucket = "lambda-${var.project_name}-${var.namespace}-${var.environment}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.cur_s3_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_s3_bucket_cors_configuration" "cur_cors" {
  bucket = aws_s3_bucket.cur_s3_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = [var.environment == "local" ? "http://${var.front_domain_name}" : "https://${var.front_domain_name}"]
  }
}
