locals {
  listener = {
    http          = { port = 80, protocol = "HTTP", action = { type = "forward" }, ssl_policy = null }
    http_redirect = { port = 80, protocol = "HTTP", action = { type = "redirect", port = 443, protocol = "HTTPS" }, ssl_policy = null }
    https         = { port = 443, protocol = "HTTPS", action = { type = "forward" }, ssl_policy = null }
  }
  # when a listener configuration is not provided then we will set some defaults
  # - if a certificate(s) is not provided then we will simply forward port 80 traffic to the target
  # - if a certificate(s) is provided then port 80 will redirect traffic to port 443 which will forward traffic to the target
  normalized_listeners = [for listener in var.listeners : merge({ ssl_policy = null }, listener)]
  listeners            = !local.listener_provided && !local.cert_provided ? [local.listener.http] : !local.listener_provided && local.cert_provided ? [local.listener.http_redirect, local.listener.https] : local.normalized_listeners

  #listeners = !local.listener_provided && !local.cert_provided ? [local.listener.http] : [local.listener.http_redirect, local.listener.https]
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
    if redirect.action.type == "redirect" && redirect.protocol == "HTTPS" && local.cert_provided
  }
  load_balancer_arn = aws_lb.alb.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = try(each.value.ssl_policy, "ELBSecurityPolicy-TLS-1-2-2017-01")
  certificate_arn   = local.certificate_arns[0]
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
locals {
  listeners_https_redirects = [
    for redirect in local.listeners : redirect
    if redirect.action.type == "redirect" && redirect.protocol == "HTTPS"
  ]
  # Create a map of "redirect_port X additional_cert" objects
  additional_certs_https_redirects = { for pair in setproduct(local.listeners_https_redirects, local.additional_certificate_objs) : "${pair[0].port}_${pair[1].cert_name}" => merge(pair[0], pair[1]) }
}
resource "aws_lb_listener_certificate" "https_redirects" {
  for_each        = local.additional_certs_https_redirects
  listener_arn    = aws_lb_listener.https_redirects[each.value.port].arn
  certificate_arn = each.value.cert_arn
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
    if forward.action.type == "forward" && forward.protocol == "HTTPS" && local.cert_provided
  }
  load_balancer_arn = aws_lb.alb.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = try(each.value.ssl_policy, "ELBSecurityPolicy-TLS-1-2-2017-01")
  certificate_arn   = local.certificate_arns[0]
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}
locals {
  listeners_https_forwards = [
    for forward in local.listeners : forward
    if forward.action.type == "forward" && forward.protocol == "HTTPS"
  ]
  # Create a map of "forward_port X additional_cert" objects
  additional_certs_https_forwards = { for pair in setproduct(local.listeners_https_forwards, local.additional_certificate_objs) : "${pair[0].port}_${pair[1].cert_name}" => merge(pair[0], pair[1]) }
}
resource "aws_lb_listener_certificate" "https_forwards" {
  for_each        = local.additional_certs_https_forwards
  listener_arn    = aws_lb_listener.https_forwards[each.value.port].arn
  certificate_arn = each.value.cert_arn
}
