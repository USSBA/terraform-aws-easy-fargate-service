resource "aws_appautoscaling_target" "ecs_target" {
  depends_on = [
    aws_ecs_service.fargate
  ]
  max_capacity       = var.max_capacity != null ? var.max_capacity : var.desired_capacity
  min_capacity       = var.min_capacity != null ? var.min_capacity : var.desired_capacity
  resource_id        = "service/${var.cluster_name}/${var.family}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  count = var.scaling_metric != null && var.scaling_threshold != null ? 1 : 0
  depends_on = [
    aws_ecs_service.fargate
  ]
  name               = "${var.family}-target-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  target_tracking_scaling_policy_configuration {
    # https://docs.aws.amazon.com/autoscaling/application/APIReference/API_PredefinedMetricSpecification.html
    predefined_metric_specification {
      predefined_metric_type = var.scaling_metric == "memory" ? "ECSServiceAverageMemoryUtilization" : var.scaling_metric == "cpu" ? "ECSServiceAverageCPUUtilization" : "undefined"
    }
    target_value       = var.scaling_threshold
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
