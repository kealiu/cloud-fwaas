# Copyright 2024 ke.liu#foxmail.com

# create the vpc
variable "vpc_cidr" {
    description = "vpc cidr"
    type = string
    default = "198.18.0.0/16"
}

variable "vpc_azs" {
    description = "vpc az"
    type = list(string)
    default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "vpc_public_subnet" {
    description = "vpc public subnet cidr"
    type = list(string)
    default = ["198.18.1.0/24", "198.18.2.0/24", "198.18.3.0/24"]
}

variable "vpc_private_subnet" {
    description = "vpc public subnet cidr"
    type = list(string)
    default = ["198.18.128.0/24", "198.18.129.0/24", "198.18.130.0/24"]
}

