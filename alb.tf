resource "aws_lb" "alb" {
  name               = "${var.family}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = length(var.public_subnet_ids) > 0 ? var.public_subnet_ids : data.aws_subnet_ids.default[0].ids
  ip_address_type    = "ipv4"

  dynamic "access_logs" {
    for_each = var.alb_log_bucket_name != "" ? ["enabled"] : []
    content {
      bucket  = var.alb_log_bucket_name
      prefix  = var.alb_log_prefix
      enabled = true
    }
  }
}
resource "aws_wafregional_web_acl_association" "alb" {
  count        = length(var.regional_waf_acl_id) == 0 ? 0 : 1
  resource_arn = aws_lb.alb.arn
  web_acl_id   = var.regional_waf_acl_id
}
