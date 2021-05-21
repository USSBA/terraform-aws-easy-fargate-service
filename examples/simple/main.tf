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
  enable_execute_command = true
}
output "alb_dns" {
  value = module.my-ez-fargate-service.alb_dns
}
