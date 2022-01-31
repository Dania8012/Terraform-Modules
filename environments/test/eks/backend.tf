terraform {
  backend "s3" {
    encrypt = true
    bucket  = "terraform-state-storage2022"
    key     = "eks/terraform.tfstate"
    region  = "eu-west-1"
  }
}
