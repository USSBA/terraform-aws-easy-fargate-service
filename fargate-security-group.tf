resource "aws_security_group" "fargate" {
  name        = "${var.family}-svc-sg"
  description = "A security group used by the ${var.family} ecs fargate service"
  vpc_id      = local.vpc_id

  dynamic "ingress" {
    for_each = { for item in local.listeners : item.port => item }
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = local.is_internal && var.vpc_id != "" ? [data.aws_vpc.other[0].cidr_block] : ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, var.tags_security_group)
}

