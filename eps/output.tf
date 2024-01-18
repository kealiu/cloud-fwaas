# Copyright 2024 ke.liu#foxmail.com

output "target_group" {
    value = resource.aws_lb_target_group.gwlb_tg
}

output "gwlb_tg" {
  value = resource.aws_lb_target_group.gwlb_tg
}

output "svc" {
    value = resource.aws_vpc_endpoint_service.ids_svc
}