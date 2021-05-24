module "my-ez-fargate-service" {
  #source  = "USSBA/easy-fargate-service/aws"
  #version = "~> 5.0"
  source = "../../"

  family         = "ez-fargate-svc-simple"
  container_port = "8080"
  container_definitions = [
    {
      name  = "python"
      image = "python:3"
      command = [
        "/bin/bash",
        "-c",
        "mkdir /root/hello; cd /root/hello; echo hello > hello.html; python3 -m http.server 8080",
      ]
    },
  ]
  tags = {
    ManagedBy = "Terraform"
    foo       = "foo"
  }
  enable_execute_command = true
}
output "alb_dns" {
  value = module.my-ez-fargate-service.alb_dns
}
