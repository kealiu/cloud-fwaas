# Copyright 2024 ke.liu#foxmail.com

data "aws_ami" "suricata" {
  most_recent = true
  filter {
    name   = "name"
    values = ["geneve/ids/ubuntu/linux/suricata"]
    
  }
  owners = ["self"]
}

module "vpc" {
    source = "./vpc"
}

module "template" {
    source = "./template"
    image_id = data.aws_ami.suricata.image_id
    vpc_cidr = module.vpc.vpc.vpc_cidr_block
    vpc_id = module.vpc.vpc.vpc_id
    key_name = var.key_name
}

module "asg" {
  source = "./asg"
  ec2_instance_type = "c6i.large"
  launch_template_id = module.template.template_id
  subnet_ids = module.vpc.vpc.private_subnets
  security_groups = [module.template.gwlb_sg.id]
}

module "svc" {
  source = "./eps"
  vpc_id = module.vpc.vpc.vpc_id
  asgs = module.asg.asgs
  subnets = module.vpc.vpc.private_subnets
}


