locals {
  # Craft the efs_volumes config.  We need one element per "fs_id + directory", and
  # a volume ID that can be referenced from the mountpoints config below
  efs_volumes = distinct([for config in var.efs_configs : {
    vol_id         = "${config.file_system_id}_${md5(config.root_directory)}"
    file_system_id = config.file_system_id
    root_directory = config.root_directory
  }])

  # Craft the container mountpoint config. We need one element per mountpoint within
  # the container, referencing a volume ID from the volume config above
  efs_container_names = distinct(var.efs_configs.*.container_name)
  efs_mountpoints = { for name in local.efs_container_names : name => [for config in var.efs_configs : {
    containerPath = config.container_path
    sourceVolume  = "${config.file_system_id}_${md5(config.root_directory)}"
    readOnly      = false
  } if config.container_name == name] }

  container_definitions = var.container_definitions

  container_definitions_with_defaults = [for container_definition in local.container_definitions : merge(
    # If we are only provided one container, offer a default port of var.container_port
    # Otherwise, the user will need to explicitly define a portMappings property that matched var.container_port
    length(local.container_definitions) == 1 ? { portMappings = [{ containerPort = var.container_port }] } : {},
    {
      essential = true
      cpu       = floor(var.task_cpu / length(local.container_definitions))
      memory    = floor(var.task_memory / length(local.container_definitions))
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.fargate.name
          awslogs-region        = var.log_group_region != "" ? var.log_group_region : local.region
          awslogs-stream-prefix = container_definition.name
        }
      },
      stopTimeout = 5
      mountPoints = try(local.efs_mountpoints[container_definition.name], [])
    },
  container_definition)]
}
resource "aws_ecs_task_definition" "fargate" {
  family                   = var.family
  container_definitions    = jsonencode(local.container_definitions_with_defaults)
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
