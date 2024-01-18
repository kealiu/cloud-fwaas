# Copyright 2024 ke.liu#foxmail.com

variable "image_id" {
  description = "the image id"
  type        = string
}

variable "principal" {
  description = "if we are in china, use ec2.amazonaws.com.cn, otherwise ec2.amazonaws.com"
  type = string
  default = "ec2.amazonaws.com"
}

# variable "instance_profile" {
#     description = "instance profile"
#     type = string
# }

variable "instance_type" {
  description = "the instance type"
  type        = string
  default     = "c6i.large"
}

variable "key_name" {
  description = "the key pair for instance"
  type        = string
}

variable "asg_tags" {
  description = "the instance type"
  type        = map(string)

  default = {
    Name = "suricata-ids"
  }
}

variable "vpc_id" {
  description = "the vpc id"
  type        = string
}

variable "vpc_cidr" {
  description = "the vpc CIDR"
  type        = string
}
