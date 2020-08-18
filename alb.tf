resource "aws_lb" "alb" {
  name               = "${var.family}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids != null ? var.public_subnet_ids : data.aws_subnet_ids.default[0].ids
  ip_address_type    = "ipv4" #TODO: set value to `dualstack` when the VPC supports ipv6

  #TODO:
  # support for access logging?
  #access_logs {
  #  bucket = ?
  #  prefix = ?
  #  enabled = false # is default
  #}
}
