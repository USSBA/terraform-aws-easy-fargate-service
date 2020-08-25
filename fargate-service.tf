resource "aws_ecs_service" "fargate" {
  depends_on = [
    aws_lb.alb,
    aws_lb_target_group.alb
  ]
  name                               = var.family
  cluster                            = "arn:aws:ecs:${local.region}:${local.account_id}:cluster/${var.cluster_name}"
  task_definition                    = aws_ecs_task_definition.fargate.arn
  desired_count                      = var.desired_capacity
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  platform_version                   = var.platform_version
  launch_type                        = "FARGATE"
  health_check_grace_period_seconds  = 10
  force_new_deployment               = true

  lifecycle {
    ignore_changes = [desired_count]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb.arn
    container_name   = var.family
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = var.private_subnet_ids != null ? var.private_subnet_ids : data.aws_subnet_ids.default[0].ids
    security_groups  = setunion([aws_security_group.fargate.id], var.security_group_ids)
    assign_public_ip = var.private_subnet_ids == null
  }
}
