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
}
resource "aws_iam_role_policy" "ecs_task" {
  count  = var.task_policy_json != null ? 1 : 0
  name   = "${var.family}-task"
  role   = aws_iam_role.ecs_task.id
  policy = var.task_policy_json
}
