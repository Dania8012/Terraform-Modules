provider "aws" {
  region = "eu-west-1"
}

data "terraform_remote_state" "eks_cluster" {
  backend = "s3"
  config = {
    bucket = "terraform-state-storage2022"
    key    = "eks/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-state-storage2022"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}

module "eks_node_group" {
  source          = "../../../../modules/eks/node_group"
  name            = data.terraform_remote_state.eks_cluster.outputs.name
  cluster_name    = data.terraform_remote_state.eks_cluster.outputs.name
  disk_size       = 20
  instance_type   = "t2.micro"
  min_size        = 1
  max_size        = 1
  desired_size    = 1
  max_unavailable = 1
  subnet_ids = ["subnet-00e191706a2403fcd", "subnet-08427e87fee75bdd8", "subnet-0e4acb80282d2a512"]
  # subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnets.*.id
}