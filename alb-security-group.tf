resource "aws_security_group" "alb_ingress" {
  name        = "${var.family}-alb"
  description = "A security group used by the ${var.family} application load balancer"
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = var.ipv6 ? ["::/0"] : []
  }
  tags = merge(var.tags, var.tags_alb, var.tags_security_group)
}

resource "aws_security_group_rule" "alb_ingress" {
  ## Only create ingress rules when there's no explicit alb_security_groups being passed in
  ## Need to keep the security group to ensure the fargate containers allow access to the ALB
  for_each = length(var.alb_security_group_ids) > 0 ? {} : { for item in local.listeners : item.port => item }

  security_group_id = aws_security_group.alb_ingress.id
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = local.is_internal && var.vpc_id != "" ? [data.aws_vpc.other[0].cidr_block] : ["0.0.0.0/0"]
  ipv6_cidr_blocks       = var.ipv6 ? ( local.is_internal && var.vpc_id != "" ? [data.aws_vpc.other[0].cidr_block] : ["::/0"] ) : []
}
