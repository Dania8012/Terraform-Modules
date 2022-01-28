#!/bin/bash
cd environments/test/vpc
terraform init
terraform plan
echo applying changes ...
terraform apply -auto-approve