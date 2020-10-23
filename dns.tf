resource "aws_route53_record" "dns" {
  count   = var.hosted_zone_id != "" && var.service_fqdn != "" ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = var.service_fqdn
  type    = "A"
  alias {
    name                   = var.use_cloudfront ? aws_cloudfront_distribution.distribution[0].domain_name : aws_lb.alb.dns_name
    zone_id                = var.use_cloudfront ? aws_cloudfront_distribution.distribution[0].hosted_zone_id : aws_lb.alb.zone_id
    evaluate_target_health = false
  }
  allow_overwrite = var.route53_allow_overwrite
}
