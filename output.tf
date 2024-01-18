# Copyright 2024 ke.liu#foxmail.com

output "template_id" {
    value = module.template.template_id
}

output "autoscaling_group" {
    value = module.asg
}

output "endpoint_services" {
    value = module.svc
}