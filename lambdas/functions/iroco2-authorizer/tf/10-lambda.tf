locals {
  lambda = {
    bucket_key    = "lambda/${var.namespace}/${var.project_name}"
    zip_path      = "${path.module}/${var.project_name}.zip"
    src_path      = "${path.module}/src/bootstrap"
    function_name = "lambda-${var.namespace}-${var.project_name}"
    handler       = var.project_name
    arch          = "arm64"
    runtime       = "provided.al2023"
    memory        = 128
    timeout       = 900
  }
}

data "archive_file" "authorizer" {
  type        = "zip"
  source_file = local.lambda.src_path
  output_path = local.lambda.zip_path
}

resource "aws_s3_object" "authorizer" {
  bucket      = aws_s3_bucket.lambda_s3_bucket.bucket
  key         = local.lambda.bucket_key
  source      = data.archive_file.authorizer.output_path
  source_hash = data.archive_file.authorizer.output_md5
}

resource "aws_lambda_function" "lambda_function" {
  function_name = local.lambda.function_name
  role          = aws_iam_role.lambda_role_send.arn
  handler       = local.lambda.handler
  runtime       = local.lambda.runtime
  architectures = [local.lambda.arch]

  s3_bucket = aws_s3_bucket.lambda_s3_bucket.bucket
  s3_key    = aws_s3_object.authorizer.key

  source_code_hash = filebase64sha256(data.archive_file.authorizer.output_path)

  memory_size = local.lambda.memory

  environment {
    variables = {
      "IROCO2_KMS_IDENTITY_PUBLIC_KEY" = data.aws_kms_public_key.by_id.public_key_pem
    }
  }

  depends_on = [aws_s3_object.authorizer]

  timeout = local.lambda.timeout
}
