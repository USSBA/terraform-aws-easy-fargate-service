resource "aws_appautoscaling_scheduled_action" "actions" {
  count              = length(var.scheduled_actions)
  name               = "${var.family}-scheduled-action-${count.index}"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = var.scheduled_actions[count.index].expression
  timezone           = var.scheduled_actions_timezone

  scalable_target_action {
    min_capacity = var.scheduled_actions[count.index].min_capacity
    max_capacity = var.scheduled_actions[count.index].max_capacity
  }
}

