# Copyright 2025 Ippon Technologies
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
locals {
  layers_key       = "${var.namespace}/${var.project_name}/layers.zip"
  layers_path      = "${path.module}/../layers"
  layers_zip_path  = "${local.layers_path}/layers.zip"
  layers           = fileset(local.layers_path, "**/*.py")
  handler_key      = "${var.namespace}/${var.project_name}/handler.zip"
  handler_path     = "${path.module}/../package"
  handler_zip_path = "${local.handler_path}/cur_scrapper.zip"
}

data "archive_file" "layers" {
  type        = "zip"
  output_path = local.layers_zip_path

  dynamic "source" {
    for_each = local.layers
    content {
      filename = source.value
      content  = file("${local.layers_path}/${source.value}")
    }
  }
}

data "archive_file" "handler" {
  type        = "zip"
  source_dir  = local.handler_path
  output_path = local.handler_zip_path

  excludes = ["${basename(local.handler_zip_path)}"]
}

resource "aws_s3_bucket" "scrapper_bucket" {
  bucket = "${var.namespace}-${var.project_type}-${var.project_name}-${var.environment}"
}

resource "aws_s3_bucket_ownership_controls" "scrapper_bucket" {
  bucket = aws_s3_bucket.scrapper_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "scrapper_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.scrapper_bucket]
  bucket     = aws_s3_bucket.scrapper_bucket.id
  acl        = "private"
}

data "aws_iam_policy_document" "scrapper_bucket_policy" {
  statement {
    sid = "PublicReadForLambdaFiles"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.scrapper_bucket.arn}/${local.layers_key}",
      "${aws_s3_bucket.scrapper_bucket.arn}/${local.handler_key}"
    ]
  }

  statement {
    sid = "AllowListBucket"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.scrapper_bucket.arn
    ]
  }
}

resource "aws_s3_bucket_policy" "scrapper_bucket" {
  bucket = aws_s3_bucket.scrapper_bucket.id
  policy = data.aws_iam_policy_document.scrapper_bucket_policy.json
}

resource "aws_s3_object" "scrapper_layers" {
  bucket = aws_s3_bucket.scrapper_bucket.bucket
  key    = local.layers_key
  source = data.archive_file.layers.output_path
  etag   = filemd5(data.archive_file.layers.output_path)
  acl    = "public-read"
}

resource "aws_s3_object" "scrapper_handler" {
  bucket = aws_s3_bucket.scrapper_bucket.bucket
  key    = local.handler_key
  source = data.archive_file.handler.output_path
  etag   = filemd5(data.archive_file.handler.output_path)
  acl    = "public-read"
}

resource "aws_s3_bucket_request_payment_configuration" "scrapper_bucket" {
  bucket = aws_s3_bucket.scrapper_bucket.id
  payer  = "BucketOwner"
}

resource "aws_s3_bucket_public_access_block" "scrapper_bucket" {
  bucket = aws_s3_bucket.scrapper_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

