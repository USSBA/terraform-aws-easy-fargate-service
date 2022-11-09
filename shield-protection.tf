resource "aws_shield_protection" "shield" {
  count = var.enable_shield_protection == true ? 1 : 0

  name         = var.family
  resource_arn = aws_lb.alb.arn
}
