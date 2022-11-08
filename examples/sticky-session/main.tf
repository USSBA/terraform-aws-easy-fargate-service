## This module assumes there will be an ECS Cluster named "default".  ECS creates this when you first start messing around
## in the Console, but if you have yet to do this, simply run:
##   aws ecs create-cluster --cluster-name default
module "easy-fs-sticky" {
  source = "../../"
  family = "easy-fs-sticky" # Any name to prefix created resources; should be unique among easy-fargate-services
  container_definitions = [
    {
      name  = "nginx"        # Arbitrary name for the container
      image = "nginx:latest" # The image name:tag on dockerhub
      #image = "YOUR_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/your-ecr-repo-name:your-ecr-image-tag" # Using an image pushed into ECR
    }
  ]

  alb_sticky_duration = 604800
}
module "easy-fs-sticky-app-cookie" {
  source = "../../"
  family = "easy-fs-sticky-app" # Any name to prefix created resources; should be unique among easy-fargate-services
  container_definitions = [
    {
      name  = "nginx"        # Arbitrary name for the container
      image = "nginx:latest" # The image name:tag on dockerhub
      #image = "YOUR_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/your-ecr-repo-name:your-ecr-image-tag" # Using an image pushed into ECR
    }
  ]

  alb_sticky_duration    = 604800
  alb_sticky_cookie_name = "foobar"
}
