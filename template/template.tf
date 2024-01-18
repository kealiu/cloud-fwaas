# Copyright 2024 ke.liu#foxmail.com

data "aws_key_pair" "keypair" {
  key_name  = var.key_name
}

resource "aws_security_group" "gwlb_sg" {
  name        = "GWLB_TARGET_SG"
  description = "Allow Geneve inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH, for maintances"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "VPC, all"
    from_port        = 6081
    to_port          = 6081
    protocol         = "udp"
    cidr_blocks      = [var.vpc_cidr]
  }

  ingress {
    description      = "health check"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "gwlb_sg"
  }
}

resource "aws_iam_role" "gwlb_ids_role" {
  name = "gwlb_ids_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = var.principal
        }
      },
    ]
  })
  
  tags = {
    Name = "gwlb_ids_role"
  }
}

resource "aws_iam_role_policy" "gwlb_ids_role" {
    name        = "gwlb_ids_role"
    role        = aws_iam_role.gwlb_ids_role.id

    # Terraform's "jsonencode" function converts a
    # Terraform expression result to valid JSON syntax.
  
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
            "Sid": "PermissionRequiredForCheckGWLBPrivateIP",
            "Action": [
                "ec2:DescribeNetworkInterfaces"
            ],
            "Effect": "Allow",
            "Resource": "*"
            }
        ]
    })
}

resource "aws_iam_instance_profile" "gwlb_ids_role" {
  name = "gwlb_ids_role"
  role = aws_iam_role.gwlb_ids_role.name
}


resource "aws_launch_template" "ids" {
  name_prefix = "suricata-asg-"
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 8
      volume_type = "gp3"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.gwlb_ids_role.name
  }

  image_id = var.image_id
  instance_type = var.instance_type
  key_name = data.aws_key_pair.keypair.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [resource.aws_security_group.gwlb_sg.id]
  }
  # vpc_security_group_ids = [resource.aws_security_group.gwlb_sg.id]
  tags = var.asg_tags
}