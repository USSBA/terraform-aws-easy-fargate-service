module "my-ez-fargate-service" {
  source  = "USSBA/easy-fargate-service/aws"
  version = "~> 4.0"

  family             = "my-ez-fargate-service"
  container_image    = "nginx:latest"
  cluster_name       = "my-ecs-cluster"
  vpc_id             = "vpc-1234abcd"
  private_subnet_ids = ["subnet-11111111", "subnet-22222222", "subnet-33333333"]
}

