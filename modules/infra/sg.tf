resource "aws_security_group" "lb_sg" {
  name        = "lb-security-group"
  description = "Load balancer security group"
  vpc_id      = aws_vpc.ghost-vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_tasks_sg" {
  name        = "ecs-tasks-security-group"
  description = "ECS tasks security group"
  vpc_id      = aws_vpc.ghost-vpc.id

  // Allow incoming traffic from the load balancer on Ghost port
  ingress {
    protocol        = "tcp"
    from_port       = 2368
    to_port         = 2368
    security_groups = [aws_security_group.lb_sg.id]
  }

  // Allow all outbound traffic (needed to pull images, access AWS APIs, connect to RDS)
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
