module "my-ez-fargate-service" {
  #source             = "USSBA/easy-fargate-service/aws"
  #version            = "~> 3.0"
  source = "../../"
  family = "ez-fargate-svc-simple"
  container_definitions = [
    {
      name  = "nginx"
      image = "nginx:latest"
    },
  ]
}
output "alb_dns" {
  value = module.my-ez-fargate-service.alb_dns
}
