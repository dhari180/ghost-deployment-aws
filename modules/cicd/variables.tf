variable "ecs_cluster_name" {
  type        = string
  description = "name of the ecs cluster to deploy to"
}

variable "ecs_service_name" {
  type        = string
  description = "name of the ecs service to deploy to"
}

variable "target_group_name" {
  type        = string
  description = "name of the target group for blue/green deployment"
}

variable "listener_arn" {
  type        = string
  description = "ARN of the load balancer listener"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of the ECS task execution role"
}

variable "db_host" {
  type        = string
  description = "RDS MySQL database host"
}

variable "db_password" {
  type        = string
  description = "RDS MySQL database password"
  sensitive   = true
}

variable "ghost_url" {
  type        = string
  description = "Public URL for Ghost"
}