resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${local.lambda.function_name}"
  retention_in_days = 1
}

resource "aws_iam_role_policy" "lambda_log" {
  name   = "lambda-log-${local.lambda.function_name}"
  role   = aws_iam_role.lambda_role_send.id
  policy = data.aws_iam_policy_document.log_cloud.json
}
