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
resource "aws_s3_bucket" "cfn_bucket" {
  bucket = "${var.namespace}-cfn-templates-${var.environment}"
}

resource "aws_s3_bucket_ownership_controls" "cfn_bucket" {
  bucket = aws_s3_bucket.cfn_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cfn_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.cfn_bucket]
  bucket     = aws_s3_bucket.cfn_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_public_access_block" "cfn_bucket" {
  bucket = aws_s3_bucket.cfn_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "cfn_bucket_policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.cfn_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "cfn_bucket" {
  bucket = aws_s3_bucket.cfn_bucket.id
  policy = data.aws_iam_policy_document.cfn_bucket_policy.json
}

resource "aws_s3_bucket_request_payment_configuration" "cfn_bucket" {
  bucket = aws_s3_bucket.cfn_bucket.id
  payer  = "BucketOwner"
}

resource "aws_s3_object" "lambda_yaml" {
  bucket = aws_s3_bucket.cfn_bucket.bucket
  key    = "lambda.yaml"
  source = "${path.module}/../lambda.yaml"
  etag   = filemd5("${path.module}/../lambda.yaml")
  acl    = "public-read"
}

output "lambda_yaml_url" {
  description = "URL of the publicly accessible lambda.yaml file"
  value       = "https://${aws_s3_bucket.cfn_bucket.bucket}.s3.${data.aws_region.current.name}.amazonaws.com/lambda.yaml"
}
