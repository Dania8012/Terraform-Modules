#!/bin/bash
cd environments/test
terraform init
terraform plan
echo applying changes ...
terraform apply -auto-approve