module "easy-fargate" {
  #source  = "USSBA/easy-fargate-service/aws"
  #version = "~> 6.0"
  source = "../../"

  family         = "easy-fargate-svc-deploy"
  container_port = "8080"
  container_definitions = [
    {
      name  = "python"
      image = "python:3"
      command = [
        ## To test a deployment failure, uncomment the line below
        #"bad-command-that-will-cause-a-failure",
        "/bin/bash",
        "-c",
        "mkdir /root/hello; cd /root/hello; echo hello3 > hello.html; python3 -m http.server 8080",
      ]
    },
  ]
  enable_deployment_rollbacks = true
  wait_for_steady_state       = true
}
output "alb_dns" {
  value = module.easy-fargate.alb_dns
}
