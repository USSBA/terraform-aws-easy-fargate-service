module "my-ez-fargate-efs" {
  #source             = "USSBA/easy-fargate-service/aws"
  #version            = "~> 2.2"
  source          = "../../"
  family          = "ez-fargate-svc-efs"
  container_image = "nginx:latest"
  task_cpu        = "1024"
  task_memory     = "2048"

  efs_configs = [
    # Mount 1: efs-one:/ => container:/mnt/one_a
    # Mount 2: efs-one:/ => container:/mnt/one_b
    #   Shares a task Volume with Mount 1
    # Mount 3: efs-two:/ => container:/mnt/two
    # Container will have access to directories:
    #   /mnt/one_a
    #   /mnt/one_b
    #   /mnt/two
    {
      file_system_id = aws_efs_file_system.efs-one.id
      root_directory = "/"
      container_path = "/mnt/one_a"
    },
    {
      file_system_id = aws_efs_file_system.efs-one.id
      root_directory = "/"
      container_path = "/mnt/one_b"
    },
    {
      file_system_id = aws_efs_file_system.efs-two.id
      root_directory = "/"
      container_path = "/mnt/two"
    },
  ]
}

# Allow Fargate task into EFS
resource "aws_security_group_rule" "allow_fargate_into_efs" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = module.my-ez-fargate-efs.security_group_id
}
