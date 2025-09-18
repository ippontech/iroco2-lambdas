# Variables for the basic example

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "iroco2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "data-team"
}

variable "kms_key_id" {
  description = "KMS key ID or alias for encryption (must support ENCRYPT_DECRYPT)"
  type        = string
  # Example: "alias/aws/s3" or "12345678-1234-1234-1234-123456789012"
}

variable "aws_org_id" {
  description = "AWS Organization ID for access control"
  type        = string
  # Example: "o-1234567890"
}

variable "iroco2_api_endpoint" {
  description = "IROCO2 API endpoint URL"
  type        = string
  # Example: "https://api.iroco2.example.com"
}

variable "iroco2_gateway_endpoint" {
  description = "IROCO2 Gateway endpoint URL"
  type        = string
  # Example: "https://gateway.iroco2.example.com"
}

variable "iroco2_api_key" {
  description = "IROCO2 API authentication key"
  type        = string
  sensitive   = true
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 900
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512
}
