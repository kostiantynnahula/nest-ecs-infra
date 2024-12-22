output "organization_db_address" {
  value = aws_db_instance.organization.address
}

output "organization_db_port" {
  value = aws_db_instance.organization.port
}

output "organization_db_name" {
  value = aws_db_instance.organization.db_name
}

# output "patient_db_address" {
#   value = aws_db_instance.patient.address
# }

# output "patient_db_port" {
#   value = aws_db_instance.patient.port
# }

# output "patient_db_name" {
#   value = aws_db_instance.patient.db_name
# }

output "cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "alb_lb_listener_rule_arn" {
  value = aws_lb_listener.alb_listener.arn
}

output "ecs_service_sg_id" {
  value = aws_security_group.ecs_service_sg.id
}

output "default_vpc_id" {
  value = aws_default_vpc.default_vpc.id
}

output "default_subnet_a_id" {
  value = aws_default_subnet.default_subnet_a.id
}

output "default_subnet_b_id" {
  value = aws_default_subnet.default_subnet_b.id
}

output "db_subnet_group_id" {
  value = aws_db_subnet_group.db_subnet_group.id
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecsTaskExecutionRole.arn
}

output "app_url" {
  value = aws_alb.application_load_balancer.dns_name
}
