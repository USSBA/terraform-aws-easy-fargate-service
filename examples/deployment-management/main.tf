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

  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
  lights_on_schedule_expr = "cron(0 8 * * ? *)" # Turn on at 8AM in the timezone (and will adjust for DST if the time-zone uses it)
  lights_off_schedule_expr = "cron(0 8 * * ? *)" # Turn off at 6PM in the timezone (and will adjust for DST if the time-zone uses it)
  schedule_timezone = "America/New_York"

}
output "alb_dns" {
  value = module.easy-fargate.alb_dns
}
