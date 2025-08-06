data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "data" {
  backend = "s3"

  config = {
    key    = "infrastructure/eu-west-3/data/terraform.tfstate"
  }
}

data "aws_kms_public_key" "by_id" {
  key_id = data.terraform_remote_state.data.outputs.iroco_identity_provider_key_id
}
