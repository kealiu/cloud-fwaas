# Copyright 2024 ke.liu#foxmail.com

module "security_vpc" {
    source = "terraform-aws-modules/vpc/aws"
    name   = "security_vpc"

    cidr = var.vpc_cidr
    azs  = var.vpc_azs
    public_subnets   = var.vpc_public_subnet
    private_subnets  =var.vpc_private_subnet

    enable_nat_gateway = true
    single_nat_gateway = true
    one_nat_gateway_per_az = false
    tags = {
        Terraform = "true"
    }
}
