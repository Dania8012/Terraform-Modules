#!/bin/bash
terraform plan
echo applying changes ...
terraform apply -auto-approve