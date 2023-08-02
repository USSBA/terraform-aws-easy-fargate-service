module "my-ez-fargate-efs" {
  #source             = "USSBA/easy-fargate-service/aws"
  #version            = "~> 6.0"

  vpc_id             = data.aws_vpc.default.id
  private_subnet_ids = toset(data.aws_subnets.default.ids)

  source         = "../../"
  family         = "ez-fargate-svc-efs"
  task_cpu       = "1024"
  task_memory    = "2048"
  container_port = 80
  container_definitions = [
    {
      name         = "nginx"
      image        = "mohamnag/nginx-file-browser:latest"
      portMappings = [{ containerPort = 80 }]
    },
    {
      name      = "file-toucher"
      image     = "ubuntu:latest"
      essential = false
      command = ["bash", "-cx", <<-EOT
         apt update;
         apt install tree -y;
         tree /mnt;
         touch /mnt/one_a/foo-`date -Iminutes`;
         tree /mnt;
         touch /mnt/one_b/bar-`date -Iminutes`;
         tree /mnt;
         touch /mnt/two/baz-`date -Iminutes`;
         tree /mnt;
       EOT
      ]
    }
  ]

  efs_configs = [
    # "nginx" container mounts
    # Mount 1: efs-one:/ => container:/opt/www/files/one_a
    # Mount 2: efs-one:/ => container:/opt/www/files/one_b
    #   Shares a task Volume with Mount 1
    # Mount 3: efs-two:/ => container:/opt/www/files/two
    # Container will have access to directories:
    #   /opt/www/files/one_a
    #   /opt/www/files/one_b
    #   /opt/www/files/two
    {
      container_name = "nginx"
      file_system_id = aws_efs_file_system.efs-one.id
      root_directory = "/"
      container_path = "/opt/www/files/one_a"
    },
    {
      container_name = "nginx"
      file_system_id = aws_efs_file_system.efs-one.id
      root_directory = "/"
      container_path = "/opt/www/files/one_b"
    },
    {
      container_name = "nginx"
      file_system_id = aws_efs_file_system.efs-two.id
      root_directory = "/"
      container_path = "/opt/www/files/two"
    },
    # "file-toucher" container mounts
    # Mount 1: efs-one:/ => container:/mnt/one_a
    # Mount 2: efs-one:/ => container:/mnt/one_b
    #   Shares a task Volume with Mount 1
    # Mount 3: efs-two:/ => container:/mnt/two
    # Container will have access to directories:
    #   /mnt/one_a
    #   /mnt/one_b
    #   /mnt/two
    {
      container_name = "file-toucher"
      file_system_id = aws_efs_file_system.efs-one.id
      root_directory = "/"
      container_path = "/mnt/one_a"
    },
    {
      container_name = "file-toucher"
      file_system_id = aws_efs_file_system.efs-one.id
      root_directory = "/"
      container_path = "/mnt/one_b"
    },
    {
      container_name = "file-toucher"
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

output "alb_dns" {
  value = module.my-ez-fargate-efs.alb_dns
}
