data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  count   = local.subnet_ids_provided ? 0 : 1
  default = true
}

data "aws_subnet_ids" "default" {
  count  = local.subnet_ids_provided ? 0 : 1
  vpc_id = local.vpc_id
}

locals {
  region              = data.aws_region.current.name
  account_id          = data.aws_caller_identity.current.account_id
  subnet_ids_provided = var.private_subnet_ids != null && var.public_subnet_ids != null
  vpc_id              = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default[0].id
}
