module "ez-fargate" {
  source                 = "../../"
  family                 = "ez-fargate-nonpersistent"
  task_cpu               = "256"
  task_memory            = "512"
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
      essential = true
      command = ["bash", "-cx", <<-EOT
         while true; do touch /mnt/ft_nonpersistent_files/touch-`date -Iminutes`; sleep 60; done;
       EOT
      ]
    }
  ]
  nonpersistent_volume_configs = [
    # container mounts
    # Mount 1: volume nps:/ => nginx:/mnt/nginx_nonpersistent_files
    {
      volume_name    = "nps"
      container_name = "nginx"
      container_path = "/opt/www/files/nginx_nonpersistent_files"
    },
    # Mount 2: volume nps:/ => file-toucher:/mnt/ft_nonpersistent_files
    {
      volume_name    = "nps"
      container_name = "file-toucher"
      container_path = "/mnt/ft_nonpersistent_files"
    },
  ]

  wait_for_steady_state       = true # Don't finish tf apply until containers are actually running (so the ALB link works immediately upon display)
}

output "alb_dns" {
  value = module.ez-fargate.alb_dns
}
