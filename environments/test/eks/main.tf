module "eks_cluster" {
  source     = "../../../modules/eks"
  name       = "example"
  subnet_ids = ["subnet-00e191706a2403fcd", "subnet-08427e87fee75bdd8", "subnet-0e4acb80282d2a512"]
}