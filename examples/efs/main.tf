resource "aws_efs_file_system" "efs-one" {
  creation_token = "my-efs-one"

  tags = {
    Name = "my-efs-one"
  }
}

resource "aws_efs_file_system" "efs-two" {
  creation_token = "my-efs-two"

  tags = {
    Name = "my-efs-two"
  }
}


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
