# Basic example of using the IROCO2 Client Side Scanner module

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources for existing resources
data "aws_kms_key" "existing" {
  key_id = var.kms_key_id
}

# Example S3 buckets (you may want to use existing ones)
resource "aws_s3_bucket" "lambda_artifacts" {
  bucket = "${var.project_name}-lambda-artifacts-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Use the IROCO2 Client Side Scanner module
module "iroco2_scanner" {
  source = "../"

  # Required variables
  kms_key_arn                = data.aws_kms_key.existing.arn
  layer_bucket_storage       = aws_s3_bucket.lambda_artifacts.bucket
  layer_bucket_key          = aws_s3_object.lambda_layer.key
  aws_org_id                = var.aws_org_id
  cur_output_bucket_name    = "${var.project_name}-cur-output-${random_id.suffix.hex}"
  cur_function_s3_key       = aws_s3_object.lambda_function.key
  cur_function_s3_bucket    = aws_s3_bucket.lambda_artifacts.bucket
  iroco2_api_endpoint       = var.iroco2_api_endpoint
  iroco2_gateway_endpoint   = var.iroco2_gateway_endpoint
  iroco2_api_key           = var.iroco2_api_key

  # Optional customization
  lambda_function_name = "${var.project_name}-cur-scanner"
  lambda_timeout       = var.lambda_timeout
  lambda_memory_size   = var.lambda_memory_size

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    Repository  = "https://github.com/ippontech/iroco2-lambdas"
  }
}

# Outputs
output "lambda_function_arn" {
  description = "ARN of the deployed Lambda function"
  value       = module.iroco2_scanner.lambda_function_arn
}

output "s3_bucket_name" {
  description = "Name of the CUR output S3 bucket"
  value       = module.iroco2_scanner.s3_bucket_name
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for monitoring"
  value       = module.iroco2_scanner.cloudwatch_log_group_name
}
