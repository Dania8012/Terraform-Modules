############################
# Credentials
############################
provider "aws" {
  region = "eu-west-1"
}

# VPC
module "vpc" {
  source = "../../../modules/VPC"

  name = "CofeApp-VPC"
  subnet_prefix = "CofeApp"
  #env = var.global_env
  cidr = "192.168.0.0/16"

  azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  ## Production Subnets
  public_subnets          = ["192.168.11.0/24", "192.168.12.0/24", "192.168.13.0/24"]
  internet_access_subnets = ["192.168.31.0/24", "192.168.32.0/24", "192.168.33.0/24"]
  private_subnets         = ["192.168.21.0/24", "192.168.22.0/24", "192.168.23.0/24"]
  

  enable_nat_gateway = true
  enable_vpn_gateway = false
  enable_s3_endpoint = false

  tags = {
    Terraform = "true"
  }
}
