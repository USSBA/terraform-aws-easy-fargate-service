resource "aws_lb" "alb" {
  name                       = replace("${var.family}-alb", "_", "-") # Convert underscores to hyphens to support the ALB API
  internal                   = local.is_internal
  load_balancer_type         = "application"
  security_groups            = var.alb_security_group_ids
  subnets                    = local.is_internal ? var.private_subnet_ids : var.public_subnet_ids
  ip_address_type            = var.ipv6 ? "dualstack" : "ipv4"
  idle_timeout               = var.alb_idle_timeout
  drop_invalid_header_fields = var.alb_drop_invalid_header_fields
  tags                       = merge(var.tags, var.tags_alb)

  dynamic "access_logs" {
    for_each = var.alb_log_bucket_name != "" ? ["enabled"] : []
    content {
      bucket  = var.alb_log_bucket_name
      prefix  = var.alb_log_prefix
      enabled = true
    }
  }
}

resource "aws_wafv2_web_acl_association" "alb" {
  count        = length(var.regional_waf_acl) > 0 ? 1 : 0
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = var.regional_waf_acl
}
