resource "aws_cloudwatch_log_group" "fargate" {
  name              = var.log_group_name != "" ? var.log_group_name : var.family
  retention_in_days = var.log_group_retention_in_days
}
