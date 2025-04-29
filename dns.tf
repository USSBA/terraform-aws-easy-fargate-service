resource "aws_route53_record" "dns" {
  count           = var.hosted_zone_id != "" && var.service_fqdn != "" ? 1 : 0
  zone_id         = var.hosted_zone_id
  name            = var.service_fqdn
  type            = "A"
  allow_overwrite = var.route53_allow_overwrite
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "dns_ipv6" {
  count           = var.ipv6 && var.hosted_zone_id != "" && var.service_fqdn != "" ? 1 : 0
  zone_id         = var.hosted_zone_id
  name            = var.service_fqdn
  type            = "AAAA"
  allow_overwrite = var.route53_allow_overwrite
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = false
  }
}
