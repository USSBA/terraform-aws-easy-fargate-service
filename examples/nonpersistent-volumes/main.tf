module "ez-fargate" {
  source                 = "../../"
  family                 = "ez-fargate-nonpersistent"
  task_cpu               = "1024"
  task_memory            = "2048"
  container_port         = 80
  enable_execute_command = true
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
  nonpersistent_volume_configs = [
    # "nginx" container mounts
    # Mount 1: nps-one:/ => container:/opt/www/files/one_a
    # Mount 2: nps-one:/ => container:/opt/www/files/one_b
    #   Shares a task Volume with Mount 1
    # Mount 3: nps-two:/ => container:/opt/www/files/two
    # Container will have access to directories:
    #   /opt/www/files/one_a
    #   /opt/www/files/one_b
    #   /opt/www/files/two
    {
      volume_name    = "nps-one"
      container_name = "nginx"
      container_path = "/opt/www/files/one_a"
    },
    {
      volume_name    = "nps-one"
      container_name = "nginx"
      container_path = "/opt/www/files/one_b"
    },
    {
      volume_name    = "nps-two"
      container_name = "nginx"
      container_path = "/opt/www/files/two"
    },
    # "file-toucher" container mounts
    # Mount 1: nps-one:/ => container:/mnt/one_a
    # Mount 2: nps-one:/ => container:/mnt/one_b
    #   Shares a task Volume with Mount 1
    # Mount 3: nps-two:/ => container:/mnt/two
    # Container will have access to directories:
    #   /mnt/one_a
    #   /mnt/one_b
    #   /mnt/two
    {
      volume_name    = "nps-one"
      container_name = "file-toucher"
      container_path = "/mnt/one_a"
    },
    {
      volume_name    = "nps-one"
      container_name = "file-toucher"
      container_path = "/mnt/one_b"
    },
    {
      volume_name    = "nps-two"
      container_name = "file-toucher"
      container_path = "/mnt/two"
    },
  ]
}
