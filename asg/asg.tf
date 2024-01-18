
# Copyright 2024 ke.liu#foxmail.com

locals {
  subnets = {
    one = var.subnet_ids[0]
    two = var.subnet_ids[1]
    three = var.subnet_ids[2]
  }
}
# create the auto scalling group
resource "aws_autoscaling_group" "asg" {

    for_each = local.subnets

    name = "fw_asg-${each.value}"
    vpc_zone_identifier = [each.value]
    #vpc_zone_identifier = var.subnet_ids

    min_size    = 1
    max_size    = 3
    desired_capacity = 1
    health_check_type= "EC2"

    launch_template {
      id = var.launch_template_id
    }

    tag {
        key = "Name"
        value     = "suricata-asg-${each.value}"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_policy" "suricata_policy_up" {
  for_each = aws_autoscaling_group.asg
  name = "suricata_policy_up-${each.value.name}"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 180
  autoscaling_group_name = each.value.name
}

resource "aws_cloudwatch_metric_alarm" "suricata_cpu_alarm_up" {
  for_each = aws_autoscaling_group.asg
  alarm_name = "suricata_cpu_alarm_up-${each.value.name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "80"

  dimensions = {
    AutoScalingGroupName = each.value.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [ aws_autoscaling_policy.suricata_policy_up[each.key].arn ]
}

resource "aws_autoscaling_policy" "suricata_policy_down" {
  for_each = aws_autoscaling_group.asg
  name = "suricata_policy_down-${each.value.name}"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 180
  autoscaling_group_name = each.value.name
}

resource "aws_cloudwatch_metric_alarm" "suricata_cpu_alarm_down" {
  for_each = aws_autoscaling_group.asg
  alarm_name = "suricata_cpu_alarm_down-${each.value.name}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "50"

  dimensions = {
    AutoScalingGroupName = each.value.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [ aws_autoscaling_policy.suricata_policy_down[each.key].arn ]
}

