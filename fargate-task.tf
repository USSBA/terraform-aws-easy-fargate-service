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
        entryPoint  = length(var.entrypoint_override) > 0 ? var.entrypoint_override : null
        command     = length(var.command_override) > 0 ? var.command_override : null
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.fargate.name
            awslogs-region        = var.log_group_region != "" ? var.log_group_region : local.region
            awslogs-stream-prefix = var.log_group_stream_prefix
          }
        }
        mountPoints  = local.efs_mountpoints
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
    iterator = volume
    for_each = local.efs_volumes
    content {
      name = volume.value.vol_id
      efs_volume_configuration {
        file_system_id     = volume.value.file_system_id
        root_directory     = volume.value.root_directory
        transit_encryption = "ENABLED"
      }
    }
  }
}

locals {
  # Join var.efs_config and var.efs_configs to allow for backwards compatibility
  efs_configs = flatten(concat(var.efs_config != null ? [var.efs_config] : [], var.efs_configs))

  # Craft the efs_volumes config.  We need one element per "fs_id + directory", and
  # a volume ID that can be referenced from the mountpoints config below
  efs_volumes = distinct([for config in local.efs_configs : {
    vol_id         = md5("${config.file_system_id}-${config.root_directory}")
    file_system_id = config.file_system_id
    root_directory = config.root_directory
  }])

  # Craft the container mountpoint config. We need one element per mountpoint within
  # the container, referencing a volume ID from the volume config above
  efs_mountpoints = [for config in local.efs_configs : {
    containerPath = config.container_path
    sourceVolume  = md5("${config.file_system_id}-${config.root_directory}")
    readOnly      = false
  }]
}
