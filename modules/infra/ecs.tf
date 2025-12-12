resource "aws_ecs_cluster" "ghost-cluster" {
  name = "ghost-cluster"
}

resource "aws_ecs_task_definition" "ghost-ecs-task_definition" {
  family                   = "my_task_family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  cpu                      = "1024"
  memory                   = "2048"

  container_definitions = jsonencode([{
    name      = "ghost-container",
    #image     = "${var.ecr-repo-url}:latest",
    #image for first deployment
    image     = "ghost:latest",
    cpu       = 1024,
    memory    = 2048,
    essential = true,
    portMappings = [{
      containerPort = 2368,
      hostPort      = 2368
    }],
    environment = [
      {
        name  = "database__client",
        value = "mysql"
      },
      {
        name  = "database__connection__host",
        value = aws_db_instance.ghost_mysql.address
      },
      {
        name  = "database__connection__user",
        value = "ghostadmin"
      },
      {
        name  = "database__connection__password",
        value = var.db_password
      },
      {
        name  = "database__connection__database",
        value = "ghost"
      },
      {
        name  = "url",
        value = "http://${aws_lb.ghost-lb.dns_name}"
      }
    ],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name,
        awslogs-region        = data.aws_region.current.name,
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/ghost"
  retention_in_days = 30
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_service" "ghost-ecs-serivce" {
  name            = "ghost-service"
  cluster         = aws_ecs_cluster.ghost-cluster.id
  task_definition = aws_ecs_task_definition.ghost-ecs-task_definition.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets         = aws_subnet.private_subnet[*].id
    security_groups = [aws_security_group.ecs_tasks_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my_tg.arn
    container_name   = "ghost-container"
    container_port   = 2368
  }

  lifecycle {
    ignore_changes = [task_definition, load_balancer]
  }
}