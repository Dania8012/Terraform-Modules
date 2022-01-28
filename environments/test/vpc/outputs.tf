output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "internet_access_subnets" {
  value = module.vpc.internet_access_subnets
}

output "vpc" {
  value = module.vpc.vpc
}

