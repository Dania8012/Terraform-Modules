#!/bin/bash

# create VPC
cd environments/test/vpc
terraform init
terraform plan
terraform destroy -auto-approve

# create terraform CodeBuild project
cd ../codebuild/terraform
terraform init
terraform plan
terraform apply -auto-approve

# create terraform CodePipeline project
cd ../../codepipeline/terraform
terraform init
terraform plan
terraform apply -auto-approve

cd ../../rds
terraform init
terraform plan
terraform apply -auto-approve