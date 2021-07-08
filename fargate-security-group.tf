resource "aws_security_group" "fargate" {
  name        = "${var.family}-svc-sg"
  description = "A security group used by the ${var.family} ecs fargate service"
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, var.tags_security_group)
}

resource "aws_security_group_rule" "fargate_ingress_alb" {
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.fargate.id
  source_security_group_id = aws_security_group.alb_ingress.id
  description              = "Allow ALB to access Fargate Service"
}
