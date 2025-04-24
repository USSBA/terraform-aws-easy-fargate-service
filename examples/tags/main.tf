module "tagged_service" {
  #source             = "USSBA/easy-fargate-service/aws"
  #version            = "~> 3.0"
  source = "../../"
  family = "easy-fargate-svc-tags"
  container_definitions = [
    {
      name  = "nginx"
      image = "nginx:latest"
    },
  ]
  tags = {
    ManagedBy = "Terraform"
    foo       = "Written by tags"
  }
  tags_ecs = {
    relatesToECS = "Very Yes"
    foo          = "Written by tags_ecs"
  }
  tags_ecs_task_definition = {
    isECSTaskDefinition = "Very Yes"
    foo                 = "Written by tags_ecs_task_definition"
  }
  tags_ecs_service = {
    isECSService = "Very Yes"
    foo          = "Written by tags_ecs_service"
  }
  tags_security_group = {
    isSecurityGroup = "Very Yes"
    foo             = "Written by tags_security_group"
  }
  tags_alb = {
    relatesToALB = "Very Yes"
    foo          = "Written by tags_alb"
  }
  tags_alb_tg = {
    isTargetGroup = "Very Yes"
    foo           = "Written by tags_alb_tg"
  }
  tags_iam_role = {
    isRole = "Very Yes"
    foo    = "Written by tags_iam_role"
  }
}
output "alb_dns" {
  value = module.tagged_service.alb_dns
}
