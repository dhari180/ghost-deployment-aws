resource "aws_lb" "ghost-lb" {
  name               = "main-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.ghost-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
}

resource "aws_lb_target_group" "my_tg" {
  name        = "ghost-tg-ip"
  port        = 2368
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ghost-vpc.id
  target_type = "ip"

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200-399"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "my_tg_green" {
  name        = "ghost-tg-ip-green"
  port        = 2368
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ghost-vpc.id
  target_type = "ip"

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200-399"
  }

  lifecycle {
    create_before_destroy = true
  }
}