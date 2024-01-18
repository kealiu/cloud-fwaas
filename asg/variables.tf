
# Copyright 2024 ke.liu#foxmail.com

variable "ec2_instance_type" {
  description = "the ec2 instance type"
  default     = "c6i.large"
}

variable "launch_template_id" {
  description = "the launch template id"
  type        = string
}

variable "subnet_ids" {
  description = "the subnet ids of target"
  type        = list(string)
}

variable "security_groups" {
  description = "the security groups of asg"
  type = list(string)
}

