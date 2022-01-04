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
  name = replace("${var.family}-${random_string.tg_suffix.result}", "_", "-") # Convert underscores to hyphens to support the ALB API
  #name_prefix          = substr(var.family, 0, 6)
  port                 = var.container_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = local.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    interval            = var.health_check_interval
    path                = var.health_check_path
    port                = var.container_port
    protocol            = "HTTP"
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    matcher             = var.health_check_matcher
  }

  tags = merge(var.tags, var.tags_alb, var.tags_alb_tg)

  lifecycle { create_before_destroy = true }

  stickiness {
    enabled         = var.alb_sticky_duration > 1
    cookie_duration = var.alb_sticky_duration
    type            = length(var.alb_sticky_cookie_name) > 0 ? "app_cookie" : "lb_cookie"
    cookie_name     = length(var.alb_sticky_cookie_name) > 0 ? var.alb_sticky_cookie_name : null
  }
}
