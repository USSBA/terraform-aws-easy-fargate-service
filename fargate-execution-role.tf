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
data "aws_iam_policy_document" "ecs_execution" {
  statement {
    sid    = "ServiceDefaults"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  # If secrets have been provided then an extra statement block will be created
  # that will allow the exec to pull those secrets and inject them into the container runtime.
  dynamic "statement" {
    for_each = length(var.container_secrets) > 0 ? ["enabled"] : []
    content {
      sid    = "ServiceSecrets"
      effect = "Allow"
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
      ]
      resources = var.container_secrets.*.valueFrom
    }
  }
}
resource "aws_iam_role" "ecs_execution" {
  name               = "${var.family}-exec-basic"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_principal.json
}
resource "aws_iam_role_policy" "ecs_execution" {
  name   = "${var.family}-exec-basic"
  role   = aws_iam_role.ecs_execution.id
  policy = data.aws_iam_policy_document.ecs_execution.json
}
