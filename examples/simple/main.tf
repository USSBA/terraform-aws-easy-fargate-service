module "my-ez-fargate-service" {
  #source  = "USSBA/easy-fargate-service/aws"
  #version = "~> 4.0"
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
  tags_ecs_task_definition = {
    isTaskDefinition = "Very Yes"
    foo              = "bar"
  }
  tags_security_group = {
    isSecurityGroup = "Very Yes"
    foo             = "baz"
  }
}
output "alb_dns" {
  value = module.my-ez-fargate-service.alb_dns
}
