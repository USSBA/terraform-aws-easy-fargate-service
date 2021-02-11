resource "aws_security_group" "fargate" {
  name        = "${var.family}-svc-sg"
  description = "A security group used by the ${var.family} ecs fargate service"
  vpc_id      = local.vpc_id
  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    self            = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, var.tags_security_group)
}
