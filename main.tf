terraform {
  backend "s3" {
    bucket = "ghost-terraform-bucket-13-12-2025"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}


variable "db_password" {
  type        = string
  description = "Password for the RDS MySQL database"
  sensitive   = true
}

module "infra" {
  source       = "./modules/infra"
  ecr-repo-url = module.cicd.ecr_repo_url
  db_password  = var.db_password
}

module "cicd" {
  source                 = "./modules/cicd"
  ecs_cluster_name       = module.infra.ecs_cluster_name
  ecs_service_name       = module.infra.ecs_service_name
  target_group_name      = module.infra.target_group_name
  listener_arn           = module.infra.listener_arn
  ecs_execution_role_arn = module.infra.ecs_execution_role_arn
  db_host                = module.infra.rds_endpoint
  db_password            = var.db_password
  ghost_url              = "http://${module.infra.alb_dns_name}"
}