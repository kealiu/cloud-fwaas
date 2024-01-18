# Copyright 2024 ke.liu#foxmail.com

variable "vpc_id" {
  description = "the vpc of gwlb"
  type        = string
}

variable "subnets" {
  description = "the subnet ids"
  type        = list(string)
}

variable "asgs" {
  description = "the auto scaling group id"
  type        = list(string)
}
