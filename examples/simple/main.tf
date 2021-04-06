module "my-ez-fargate-service" {
  source  = "USSBA/easy-fargate-service/aws"
  version = "~> 4.0"

  family = "ez-fargate-svc-simple"
  container_definitions = [
    {
      name  = "nginx"
      image = "nginx:latest"
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
