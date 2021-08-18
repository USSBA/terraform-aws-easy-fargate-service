resource "aws_appautoscaling_scheduled_action" "lights_on" {
  count              = length(var.lights_on_schedule_expr) == 0 ? 0 : 1
  name               = "${var.family}-lights-on"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = var.lights_on_schedule_expr
  timezone           = var.schedule_timezone

  scalable_target_action {
    min_capacity = var.min_capacity >= 0 ? var.min_capacity : var.desired_capacity
    max_capacity = var.max_capacity >= 0 ? var.max_capacity : var.desired_capacity
  }
}
resource "aws_appautoscaling_scheduled_action" "lights_off" {
  count              = length(var.lights_off_schedule_expr) == 0 ? 0 : 1
  name               = "${var.family}-lights-off"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = var.lights_off_schedule_expr
  timezone           = var.schedule_timezone

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}

