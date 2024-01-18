# Copyright 2024 ke.liu#foxmail.com

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


variable "region" {
    type    = string
    #default = "cn-northwest-1"
    default = "us-west-2"
    description = "the region of the AMI"
}

variable "source_iam_account" {
    type = string
    #default = "837727238323"
    default = "099720109477"
    description = "the owner account of the IAM owner; china region is 837727238323, and global is 099720109477"
}

variable "ami_name" {
    type    = string
    default = "geneve/ids/ubuntu/linux/suricata"
    description = "the name of the AMI"
}

variable "instance_type" {
    type    = string
    default = "c6i.large"
    description = "the instance type of build instance"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = var.ami_name
  instance_type = var.instance_type
  region        = var.region
  
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = [var.source_iam_account]
  }
  ssh_username = "ubuntu"

  tags = {
      Name = "suricata-ids"
  }
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    scripts = [
      "user-data.sh"
    ]
  }
}

