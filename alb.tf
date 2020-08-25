resource "aws_lb" "alb" {
  name               = "${var.family}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids != null ? var.public_subnet_ids : data.aws_subnet_ids.default[0].ids
  ip_address_type    = "ipv4"

  dynamic "access_logs" {
    for_each = var.alb_log_bucket_name != null ? ["enabled"] : []
    content {
      bucket  = var.alb_log_bucket_name
      prefix  = var.alb_log_prefix
      enabled = true
    }
  }
}
