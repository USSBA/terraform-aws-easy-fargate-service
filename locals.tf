data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
locals {
  region                      = data.aws_region.current.name
  account_id                  = data.aws_caller_identity.current.account_id
  is_internal                 = length(var.public_subnet_ids) == 0
  certificate_arns            = concat(var.certificate_arns, var.certificate_arn != "" ? [var.certificate_arn] : [])
  cert_provided               = length(local.certificate_arns) > 0
  certs_provided              = length(local.certificate_arns) > 1
  additional_certificate_arns = try(slice(local.certificate_arns, 1, length(local.certificate_arns)), [])
  additional_certificate_objs = [for cert in local.additional_certificate_arns : { cert_arn = cert, cert_name = regex("[^/]+$", cert) }]
  listener_provided           = length(var.listeners) > 0
}
