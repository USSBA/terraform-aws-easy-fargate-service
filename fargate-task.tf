resource "aws_ecs_task_definition" "fargate" {
  family = var.family
  container_definitions = jsonencode(
    [
      {
        name        = var.family
        image       = var.container_image
        essential   = true
        cpu         = var.task_cpu
        memory      = var.task_memory
        secrets     = var.container_secrets
        environment = var.container_environment
        entryPoint  = var.entrypoint_override
        command     = var.command_override
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.fargate.name
            awslogs-region        = var.log_group_region != null ? var.log_group_region : local.region
            awslogs-stream-prefix = var.log_group_stream_prefix
          }
        }
        mountPoints = (var.efs_config != null ? [
          {
            readOnly      = false
            containerPath = var.efs_config.container_path
            sourceVolume  = "efs-mount"
          }
        ] : [])
        portMappings = [{ containerPort = var.container_port }]
      }
  ])
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  requires_compatibilities = ["FARGATE"]

  dynamic "volume" {
    for_each = var.efs_config != null ? ["enabled"] : []
    content {
      name = "efs-mount"
      efs_volume_configuration {
        file_system_id     = var.efs_config.file_system_id
        root_directory     = var.efs_config.root_directory
        transit_encryption = "ENABLED"
      }
    }
  }
}
