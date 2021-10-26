data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  count   = local.use_default_subnets ? 1 : 0
  default = true
}

data "aws_subnet_ids" "default" {
  count  = local.use_default_subnets ? 1 : 0
  vpc_id = local.vpc_id
}

data "aws_vpc" "other" {
  count = local.is_internal && var.vpc_id != "" ? 1 : 0
  id    = var.vpc_id
}

locals {
  region                      = data.aws_region.current.name
  account_id                  = data.aws_caller_identity.current.account_id
  vpc_id                      = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default[0].id
  private_subnet_ids_provided = length(var.private_subnet_ids) > 0
  public_subnet_ids_provided  = length(var.public_subnet_ids) > 0
  use_default_subnets         = !local.private_subnet_ids_provided && !local.public_subnet_ids_provided
  is_internal                 = local.private_subnet_ids_provided && !local.public_subnet_ids_provided
  waf_global_identifier       = length(var.global_waf_acl) != 0 ? var.global_waf_acl : var.global_waf_acl_id
  waf_regional_identifier     = length(var.regional_waf_acl) != 0 ? var.regional_waf_acl : var.regional_waf_acl_id
  waf_regional                = length(local.waf_regional_identifier) != 0
  wafv1_regional              = local.waf_regional && substr(local.waf_regional_identifier, 0, 4) != "arn:"
  wafv2_regional              = !local.wafv1_regional
}
