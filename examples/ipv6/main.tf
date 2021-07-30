## In order to apply this test, you need to deploy the VPC first, then the rest
## This way a VPC id is resolved before the service kicks off:
##
## $ terraform apply -target module.vpc
## [...]
## $ terraform apply
##
## If you're on an IPv6 network, you can try to `curl -6 <alb-dns>`
## If not, try using a 3rd party validator: http://ipv6-test.com/validate.php

## Use the vpc module to create an IPv6 compatible vpc
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "ipv6-test"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_ipv6 = true
  assign_ipv6_address_on_creation = true
  private_subnet_assign_ipv6_address_on_creation = false
  public_subnet_ipv6_prefixes   = [0, 1]
  private_subnet_ipv6_prefixes  = [2, 3]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Owner       = "easy-fargate-service/ipv6"
  }
}


## This module assumes there will be an ECS Cluster named "default".  ECS creates this when you first start messing around
## in the Console, but if you have yet to do this, simply run:
##   aws ecs create-cluster --cluster-name default
module "easy-fs-ipv6" {
  source = "../../"
  family = "easy-fs-ipv6" # Any name to prefix created resources; should be unique among easy-fargate-services
  container_definitions = [
    {
      name  = "nginx"        # Arbitrary name for the container
      image = "nginx:latest" # The image name:tag on dockerhub
    }
  ]
  wait_for_steady_state = true # Ensure terraform isn't done until app is available

  ipv6 = true

  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids = module.vpc.public_subnets
}
output "easy-fs-ipv6-alb-dns" {
  value = module.easy-fs-ipv6.alb_dns
}
