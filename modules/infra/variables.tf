variable "ecr-repo-url" {
  type        = string
  description = "The ECS Repo where the task definition will pull the image from"
}

variable "db_password" {
  type        = string
  description = "Password for the RDS MySQL database"
  sensitive   = true
}