# Copyright 2024 ke.liu#foxmail.com

output "asgs" {
  value = [for asg in resource.aws_autoscaling_group.asg : asg.name]
}