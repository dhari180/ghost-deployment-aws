resource "aws_db_subnet_group" "ghost_db_subnet_group" {
  name       = "ghost-db-subnet-group"
  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    Name = "Ghost DB Subnet Group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS MySQL"
  vpc_id      = aws_vpc.ghost-vpc.id

  ingress {
    description     = "MySQL from ECS tasks"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ghost-rds-sg"
  }
}

resource "aws_db_instance" "ghost_mysql" {
  identifier           = "ghost-mysql"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  db_name              = "ghost"
  username             = "ghostadmin"
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  db_subnet_group_name   = aws_db_subnet_group.ghost_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "ghost-mysql"
  }
}

