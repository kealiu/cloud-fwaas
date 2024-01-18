#!/bin/bash

# generate the AMI
cd ami
packer init && packer build packer.pkr.hcl
cd -

# deploy VPC/ASG/GWLB/EP
terraform init
terraform apply --auto-approve

