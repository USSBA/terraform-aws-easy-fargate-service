resource "aws_security_group" "fargate" {
  name        = "${var.family}-svc-sg"
  description = "A security group used by the ${var.family} ecs fargate service"
  vpc_id      = local.vpc_id
  tags        = merge(var.tags, var.tags_security_group)
}

resource "aws_security_group_rule" "fargate_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.fargate.id
  description       = "Allows egress traffic by this container on any port to anywhere."
}

# I don't think this is necessary unless the Network is IPv6 only.
# Not exactly sure how we should make this determindation, but for the purpose of this story
# we only support IPv6 externally, and route internal traffic via ipv4
#resource "aws_security_group_rule" "fargate_egress_ipv6" {
#  count             = var.ipv6 ? 1 : 0
#  type              = "egress"
#  from_port         = 0
#  to_port           = 0
#  protocol          = "all"
#  ipv6_cidr_blocks   = ["::/0"]
#  security_group_id = aws_security_group.fargate.id
#}

resource "aws_security_group_rule" "fargate_ingress_alb" {
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.fargate.id
  source_security_group_id = aws_security_group.alb_ingress.id
  description              = "Allows ingress traffic to this container on port ${var.container_port} from the ALB"
}
