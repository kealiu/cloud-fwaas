# Copyright 2024 ke.liu#foxmail.com

output "template_id" {
    value = resource.aws_launch_template.ids.id
}

output "gwlb_sg" {
  value = resource.aws_security_group.gwlb_sg
}