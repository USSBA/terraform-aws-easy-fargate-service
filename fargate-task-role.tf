data "aws_iam_policy_document" "ecs_task_principal" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  name               = "${var.family}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_principal.json
  tags               = merge(var.tags, var.tags_iam_role)

  path                 = var.iam_role_path
  permissions_boundary = var.iam_role_permissions_boundary
}

data "aws_iam_policy_document" "ecs_task_exec" {
  count = var.enable_execute_command ? 1 : 0

  statement {
    sid    = "ECSExecMessages"
    effect = "Allow"

    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "logs:DescribeLogGroups",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ECSExecLogging"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.fargate.arn}:*"]
  }
}

resource "aws_iam_role_policy" "ecs_task_exec" {
  count = var.enable_execute_command ? 1 : 0

  name   = "${var.family}-task-ecs-exec"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_task_exec[0].json
}

resource "aws_iam_role_policy" "ecs_task_additional" {
  count = var.task_policy_json != "" ? 1 : 0

  name   = "${var.family}-task-additional"
  role   = aws_iam_role.ecs_task.id
  policy = var.task_policy_json
}