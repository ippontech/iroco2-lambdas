terraform {
  backend "s3" {
    key = "lambda-scrapper-client/eu-west-3/terraform.tfstate"
  }
}
