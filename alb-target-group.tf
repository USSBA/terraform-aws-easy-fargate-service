resource "aws_lb_target_group" "alb" {
  name                 = "${var.family}-tg"
  port                 = var.container_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = local.vpc_id
  deregistration_delay = 20

  health_check {
    interval            = 30
    path                = var.health_check_path
    port                = var.container_port
    protocol            = "HTTP"
    timeout             = 2
    healthy_threshold   = 10
    unhealthy_threshold = 10
    matcher             = "200-399"
  }

  # apparently there is a bug with NLB stickiness right now
  # and this is the work around, not sure how it will affect ALBs
  #stickiness {
  #  enabled = false
  #  type    = "lb_cookie"
  #}
}
