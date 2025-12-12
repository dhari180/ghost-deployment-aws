output "ecs_cluster_name" {
  value = aws_ecs_cluster.ghost-cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.ghost-ecs-serivce.name
}

output "target_group_name" {
  value = aws_lb_target_group.my_tg.name
}

output "listener_arn" {
  value = aws_lb_listener.my_listener.arn
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "rds_endpoint" {
  value = aws_db_instance.ghost_mysql.address
}

output "alb_dns_name" {
  value = aws_lb.ghost-lb.dns_name
}