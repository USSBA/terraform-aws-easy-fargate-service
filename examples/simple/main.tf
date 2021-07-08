## This module assumes there will be an ECS Cluster named "default".  ECS creates this when you first start messing around
## in the Console, but if you have yet to do this, simply run:
##   aws ecs create-cluster --cluster-name default
module "easy-fs-simplest" {
  source = "../../"
  family = "easy-fs-simplest" # Any name to prefix created resources; should be unique among easy-fargate-services
  container_definitions = [
    {
      name  = "nginx"        # Arbitrary name for the container
      image = "nginx:latest" # The image name:tag on dockerhub
      #image = "YOUR_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/your-ecr-repo-name:your-ecr-image-tag" # Using an image pushed into ECR
    }
  ]
}
output "easy-fs-simplest-alb-dns" {
  value = module.easy-fs-simplest.alb_dns
}
module "easy-fs-simple" {
  #source  = "USSBA/easy-fargate-service/aws"
  #version = "~> 6.0"
  source = "../../"

  family         = "easy-fs-simple" # Any name to prefix created resources; should be unique among easy-fargate-services
  container_port = "8080"           # Match the port of the service running in the container
  container_definitions = [
    {
      name  = "python"   # Any name for the container; must be unique in the list of all containers
      image = "python:3" # The image name:tag on dockerhub

      # Small script to start a simple file server with a single file
      command = [
        "/bin/bash",
        "-c",
        "mkdir /root/hello; cd /root/hello; echo hello > hello.html; python3 -m http.server 8080",
      ]
    },
  ]
  tags = {
    # Add arbitrary tags
    ManagedBy = "Terraform"
    foo       = "foo"
  }
}
output "easy-fs-simple-alb-dns" {
  value = module.easy-fs-simple.alb_dns
}
