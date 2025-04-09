resource "aws_security_group" "alb_ingress" {
  name        = "${var.family}-alb"
  description = "A security group used by the ${var.family} application load balancer"
  vpc_id      = local.vpc_id
  tags        = merge(var.tags, var.tags_alb, var.tags_security_group)
}

resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_ingress.id
  description       = "Allows egress traffic by this ALB on any port to anywhere."
}

resource "aws_security_group_rule" "alb_egress_ipv6" {
  count = var.ipv6 ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.alb_ingress.id
  description       = "Allows egress traffic by this ALB on any port to anywhere."
}

resource "aws_security_group_rule" "alb_ingress" {
  ## Only create ingress rules when there's no explicit alb_security_groups being passed in
  for_each = length(var.alb_security_group_ids) > 0 ? {} : { for item in local.listeners : item.port => item }

  type              = "ingress"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = "tcp"
  #cidr_blocks       = local.is_internal && var.vpc_id != "" ? [data.aws_vpc.other[0].cidr_block] : (var.alb_cidr_ingress != "" ? [var.alb_cidr_ingress] : ["0.0.0.0/0"])
  cidr_blocks       = local.is_internal ? [var.alb_cidr_ingress] : ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_ingress.id
  description       = "Allows ingress traffic on port ${each.value.port} to this ALB from anywhere."
}

resource "aws_security_group_rule" "alb_ingress_ipv6" {
  ## Only create ingress rules when there's no explicit alb_security_groups being passed in and IPv6 is enabled
  for_each = length(var.alb_security_group_ids) > 0 ? {} : !var.ipv6 ? {} : { for item in local.listeners : item.port => item }

  type              = "ingress"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = "tcp"
  ipv6_cidr_blocks  = local.is_internal && var.vpc_id != "" ? [data.aws_vpc.other[0].cidr_block] : ["::/0"]
  security_group_id = aws_security_group.alb_ingress.id
  description       = "Allows ingress traffic on port ${each.value.port} to this ALB from anywhere."
}
