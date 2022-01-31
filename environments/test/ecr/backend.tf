terraform {
  backend "s3" {
    encrypt = true
    bucket  = "terraform-state-storage2022"
    key     = "ecr/terraform.tfstate"
    region  = "eu-west-1"
  }
}

module "ecr" {
  source = "../../../modules/ecr"
}
