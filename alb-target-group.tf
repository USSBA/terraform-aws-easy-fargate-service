resource "random_string" "tg_suffix" {
  length  = 4
  upper   = false
  special = false
  keepers = {
    name   = var.family
    vpc_id = local.vpc_id
    port   = var.container_port
  }
}
resource "aws_lb_target_group" "alb" {
  # Excluding "name" field to allow for easier replacement when changing properties
  name = "${var.family}-${random_string.tg_suffix.result}"
  #name_prefix          = substr(var.family, 0, 6)
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

  tags = {
    Name = "${var.family}-tg"
  }

  lifecycle { create_before_destroy = true }

  # apparently there is a bug with NLB stickiness right now
  # and this is the work around, not sure how it will affect ALBs
  #stickiness {
  #  enabled = false
  #  type    = "lb_cookie"
  #}
}
