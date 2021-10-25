resource "aws_lb" "alb" {
  name               = replace("${var.family}-alb", "_", "-") # Convert underscores to hyphens to support the ALB API
  internal           = local.is_internal
  load_balancer_type = "application"
  security_groups    = concat(var.alb_security_group_ids, [aws_security_group.alb_ingress.id])
  subnets            = local.public_subnet_ids_provided ? var.public_subnet_ids : local.private_subnet_ids_provided ? var.private_subnet_ids : data.aws_subnet_ids.default[0].ids
  ip_address_type    = var.ipv6 ? "dualstack" : "ipv4"
  idle_timeout       = var.alb_idle_timeout

  dynamic "access_logs" {
    for_each = var.alb_log_bucket_name != "" ? ["enabled"] : []
    content {
      bucket  = var.alb_log_bucket_name
      prefix  = var.alb_log_prefix
      enabled = true
    }
  }
  tags = merge(var.tags, var.tags_alb)
}
resource "aws_wafregional_web_acl_association" "alb" {
  count        = local.wafv1_regional ? 1 : 0
  resource_arn = aws_lb.alb.arn
  web_acl_id   = local.waf_regional_identifier
}
resource "aws_wafv2_web_acl_association" "alb" {
  count        = local.wafv2_regional ? 1 : 0
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = local.waf_regional_identifier
}
