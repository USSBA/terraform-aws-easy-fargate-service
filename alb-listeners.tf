locals {
  listener = {
    http          = { port = 80, protocol = "HTTP", action = { type = "forward" } }
    http_redirect = { port = 80, protocol = "HTTP", action = { type = "redirect", port = 443, protocol = "HTTPS" } }
    https         = { port = 443, protocol = "HTTPS", action = { type = "forward" } }
  }
  # when a listener configuration is not provided then we will set some defaults
  # - if a certificate is not provided then we will simply forward port 80 traffic to the target
  # - if a certificate is provided then port 80 will redirect traffic to port 443 which will forward traffic to the target
  listeners = length(var.listeners) == 0 && var.certificate_arn == "" ? [local.listener.http] : length(var.listeners) == 0 && var.certificate_arn != "" ? [local.listener.http_redirect, local.listener.https] : var.listeners
}

resource "aws_lb_listener" "http_redirects" {
  # filtering only on redirects where the protocol is HTTP
  for_each = {
    for redirect in local.listeners : redirect.port => redirect
    if redirect.action.type == "redirect" && redirect.protocol == "HTTP"
  }
  load_balancer_arn = aws_lb.alb.arn
  port              = each.value.port
  protocol          = each.value.protocol
  default_action {
    type = "redirect"
    redirect {
      host        = try(each.value.action.host, null)
      path        = try(each.value.action.path, null)
      port        = each.value.action.port
      protocol    = each.value.action.protocol
      query       = try(each.value.action.query, null)
      status_code = try(each.value.action.status_code, "HTTP_301")
    }
  }
}
resource "aws_lb_listener" "https_redirects" {
  # filtering only on redirects where the protocol is HTTPS
  for_each = {
    for redirect in local.listeners : redirect.port => redirect
    if redirect.action.type == "redirect" && redirect.protocol == "HTTPS" && var.certificate_arn != ""
  }
  load_balancer_arn = aws_lb.alb.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = try(each.value.ssl_policy, "ELBSecurityPolicy-TLS-1-1-2017-01")
  certificate_arn   = var.certificate_arn
  default_action {
    type = "redirect"
    redirect {
      host        = try(each.value.action.host, null)
      path        = try(each.value.action.path, null)
      port        = each.value.action.port
      protocol    = each.value.action.protocol
      query       = try(each.value.action.query, null)
      status_code = try(each.value.action.status_code, "HTTP_301")
    }
  }
}
resource "aws_lb_listener" "http_forwards" {
  # filtering only on forwards where the protocol is HTTP
  for_each = {
    for forward in local.listeners : forward.port => forward
    if forward.action.type == "forward" && forward.protocol == "HTTP"
  }
  load_balancer_arn = aws_lb.alb.arn
  port              = each.value.port
  protocol          = each.value.protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}
resource "aws_lb_listener" "https_forwards" {
  # filtering only on forwards where the protocol is HTTPS
  for_each = {
    for forward in local.listeners : forward.port => forward
    if forward.action.type == "forward" && forward.protocol == "HTTPS" && var.certificate_arn != ""
  }
  load_balancer_arn = aws_lb.alb.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = try(each.value.ssl_policy, "ELBSecurityPolicy-TLS-1-1-2017-01")
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}
