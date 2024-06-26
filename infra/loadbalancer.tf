resource "aws_lb" "production" {
  name               = "webapp-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.load-balancer.id]
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
}

resource "aws_lb_target_group" "default-target-group" {
  name        = "webapp-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.production-vpc.id
  target_type = "ip"

  health_check {
    path                = "/ping/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200"
  }

}

resource "aws_lb_listener" "ecs-alb-http-listener" {
  load_balancer_arn = aws_lb.production.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.webapp-ssl-cert.arn
  depends_on        = [aws_lb_target_group.default-target-group]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default-target-group.arn
  }
}
