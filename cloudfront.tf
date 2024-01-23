resource "aws_cloudfront_distribution" "distribution" {
  count           = var.use_cloudfront ? 1 : 0
  aliases         = var.service_fqdn == "" ? [] : [var.service_fqdn]
  comment         = var.family
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"
  web_acl_id      = length(local.waf_global_identifier) == 0 ? null : local.waf_global_identifier
  tags            = merge(var.tags, var.tags_cloudfront)
  restrictions {
    geo_restriction {
      restriction_type = length(var.cloudfront_whitelist_geo_restrictions) > 0 ? "whitelist" : length(var.cloudfront_blacklist_geo_restrictions) > 0 ? "blacklist" : "none"
      locations        = length(var.cloudfront_whitelist_geo_restrictions) > 0 ? var.cloudfront_whitelist_geo_restrictions : length(var.cloudfront_blacklist_geo_restrictions) > 0 ? var.cloudfront_blacklist_geo_restrictions : null
    }
  }
  dynamic "logging_config" {
    for_each = length(var.cloudfront_log_bucket_name) == 0 ? [] : ["enabled"]
    content {
      include_cookies = false
      bucket          = var.cloudfront_log_bucket_name
      prefix          = length(var.cloudfront_log_prefix) == 0 ? null : var.cloudfront_log_prefix
    }
  }
  origin {
    domain_name = aws_lb.alb.dns_name
    origin_id   = var.family
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
    dynamic "custom_header" {
      iterator = header
      for_each = var.cloudfront_origin_custom_headers
      content {
        name  = header.name
        value = header.value
      }
    }
  }
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.family
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      cookies {
        forward = "all"
      }
      headers      = concat(["Host"], var.cloudfront_whitelist_forwarded_headers)
      query_string = true
    }
  }
  viewer_certificate {
    acm_certificate_arn            = var.certificate_arn
    cloudfront_default_certificate = var.certificate_arn == ""
    minimum_protocol_version       = var.certificate_arn == "" ? "TLSv1" : "TLSv1.2_2019"
    ssl_support_method             = "sni-only"
  }
}
