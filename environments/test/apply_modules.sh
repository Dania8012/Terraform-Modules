#!/bin/bash

# create ECR repo
cd environments/test/ecr
terraform init
terraform plan
terraform apply -auto-approve

# # create VPC
# cd environments/test/vpc
# terraform init
# terraform plan
# terraform apply -auto-approve

# # create RDS
# cd ../rds
# terraform init
# terraform plan
# terraform apply -auto-approve

# # create EKS cluster
# cd ../eks
# terraform init
# terraform plan
# terraform apply -auto-approve

# # create Node Group for EKS cluster
# cd ./node_group
# terraform init
# terraform plan
# terraform apply -auto-approve