terraform {
  backend "s3" {
    key = "authorizer-service/eu-west-3/terraform.tfstate"
  }
}
