resource "aws_ecs_service" "fargate" {
  depends_on = [
    aws_lb.alb,
    aws_lb_target_group.alb
  ]
  name                               = var.family
  cluster                            = "arn:aws:ecs:${local.region}:${local.account_id}:cluster/${var.cluster_name}"
  task_definition                    = aws_ecs_task_definition.fargate.arn
  desired_count                      = var.desired_capacity
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  platform_version                   = var.platform_version
  launch_type                        = "FARGATE"
  health_check_grace_period_seconds  = 10
  enable_execute_command             = var.enable_execute_command
  force_new_deployment               = true
  tags                               = var.tags_ecs_service_enabled ? merge(var.tags, var.tags_ecs, var.tags_ecs_service) : null
  wait_for_steady_state              = var.wait_for_steady_state

  dynamic "deployment_circuit_breaker" {
    for_each = var.enable_deployment_rollbacks ? ["enabled"] : []
    content {
      enable   = true
      rollback = true
    }
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.alb.arn
    container_name   = local.container_definitions_with_defaults[0].name
    container_port   = var.container_port
  }
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = !local.is_internal
  }
}
