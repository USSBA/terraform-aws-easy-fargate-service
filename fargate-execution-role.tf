data "aws_iam_policy_document" "ecs_execution_principal" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  name               = "${var.family}-exec-basic"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_principal.json
  tags               = merge(var.tags, var.tags_iam_role)

  path                 = var.iam_role_path
  permissions_boundary = var.iam_role_permissions_boundary
}

locals {
  extracted_container_secrets = flatten([
    for container_definition in local.container_definitions : try(container_definition.secrets, [])
  ])
}

data "aws_iam_policy_document" "ecs_execution_default" {
  statement {
    sid    = "ServiceDefaults"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  # If secrets have been provided with the container definitions, allow the
  # execution role to retrieve them and inject them into the container runtime.
  dynamic "statement" {
    for_each = length(local.extracted_container_secrets) > 0 ? ["enabled"] : []

    content {
      sid    = "ServiceSecrets"
      effect = "Allow"

      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
      ]

      resources = local.extracted_container_secrets.*.valueFrom
    }
  }
}

resource "aws_iam_role_policy" "ecs_execution_default" {
  name   = "${var.family}-exec-basic"
  role   = aws_iam_role.ecs_execution.id
  policy = data.aws_iam_policy_document.ecs_execution_default.json
}

resource "aws_iam_role_policy" "ecs_execution_additional" {
  count = var.execution_policy_json != "" ? 1 : 0

  name   = "${var.family}-exec-additional"
  role   = aws_iam_role.ecs_execution.id
  policy = var.execution_policy_json
}