# Copyright 2024 ke.liu#foxmail.com

locals {
  asg_subnets = {
    one = var.asgs[0]
    two = var.asgs[1]
    three = var.asgs[2]
  }
}

resource "aws_lb_target_group" "gwlb_tg" {
  name     = "gwlb-suricata-targets"
  port     = 6081
  protocol = "GENEVE"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "HTTP"
    port = 80
  }

  tags = {
    Name = "gwlb_suricata_ids"
  }
}

resource "aws_lb" "gwlb" {
  name               = "gwlb-suricata"
  load_balancer_type = "gateway"
  subnets = var.subnets
}

resource "aws_autoscaling_attachment" "asg_attachement1" {
  for_each = local.asg_subnets
  autoscaling_group_name = each.value
  lb_target_group_arn    = resource.aws_lb_target_group.gwlb_tg.arn
}

resource "aws_lb_listener" "gwlb_listener" {
  load_balancer_arn = resource.aws_lb.gwlb.arn
  default_action {
    target_group_arn = resource.aws_lb_target_group.gwlb_tg.arn
    type             = "forward"
  }
  tags = {
    Name = "gwlb_listener"
  }
}

resource "aws_vpc_endpoint_service" "ids_svc" {
  acceptance_required        = true
  gateway_load_balancer_arns = [resource.aws_lb.gwlb.arn]
  tags = {
    Name = "cloud-fwaas-services"
  }
}
