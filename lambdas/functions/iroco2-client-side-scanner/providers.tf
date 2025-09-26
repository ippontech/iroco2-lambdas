provider "aws" {
  region  = "eu-west-3"
  profile = "default"

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Module    = "iroco2-client-side-scanner"
    }
  }
}
