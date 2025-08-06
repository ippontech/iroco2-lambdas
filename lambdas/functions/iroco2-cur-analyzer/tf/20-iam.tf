data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "sqs:SendMessage"
    ]

    resources = [aws_sqs_queue.analyzer_sqs_queue.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.cur_s3_bucket.arn}/*",
      aws_s3_bucket.cur_s3_bucket.arn
    ]
  }
}

resource "aws_iam_role" "lambda_role_send" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "sqs_permissions" {
  name   = "sqs_permissions"
  role   = aws_iam_role.lambda_role_send.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

data "aws_iam_policy_document" "log_cloud" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}
