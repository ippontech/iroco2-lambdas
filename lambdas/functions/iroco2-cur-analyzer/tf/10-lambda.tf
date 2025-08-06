locals {
  lambda = {
    bucket_key    = "lambda/${var.project_name}/${var.namespace}/cur_processor"
    zip_path      = "${path.module}/cur_processor.zip"
    src_path      = "${path.module}/../src"
    function_name = "lambda-cur-processor-${var.namespace}"
    handler       = "src.handler.send_parsed_cur_to_queue_handler.lambda_handler"
    runtime       = "python3.11"
    memory        = 4096
    timeout       = 900
    layers        = [for layer in aws_lambda_layer_version.lambda_layers : layer.arn]
  }
}

data "archive_file" "cur_processor" {
  type = "zip"

  dynamic "source" {
    for_each = fileset(local.lambda.src_path, "**/*.py")
    content {
      content  = file("${local.lambda.src_path}/${source.value}")
      filename = "src/${source.value}"
    }
  }

  output_path = local.lambda.zip_path
}

resource "aws_s3_object" "cur_processor" {
  bucket = aws_s3_bucket.lambda_s3_bucket.bucket

  key    = local.lambda.bucket_key
  source = data.archive_file.cur_processor.output_path
  etag   = filemd5(data.archive_file.cur_processor.output_path)
  metadata = {
    hash = base64sha256(data.archive_file.cur_processor.output_path)
  }
}

resource "aws_lambda_function" "lambda_function" {

  function_name = local.lambda.function_name
  role          = aws_iam_role.lambda_role_send.arn
  handler       = local.lambda.handler
  runtime       = local.lambda.runtime

  s3_bucket = aws_s3_bucket.lambda_s3_bucket.bucket
  s3_key    = aws_s3_object.cur_processor.key

  source_code_hash = filebase64sha256(data.archive_file.cur_processor.output_path)

  memory_size = local.lambda.memory

  environment {
    variables = {
      "QUEUE_URL" = aws_sqs_queue.analyzer_sqs_queue.url
      "REGION"    = data.aws_region.current.name
    }
  }

  layers = local.lambda.layers

  depends_on = [aws_s3_object.cur_processor]

  timeout = local.lambda.timeout
}
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.cur_s3_bucket.arn
}
