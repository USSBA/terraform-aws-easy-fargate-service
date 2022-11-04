module "http-forward" {
  source = "../.."
  #source  = "USSBA/easy-fargate-service/aws"
  #version = "~> 6.7"

  family = "ezfs-lstn-forward"
  # A simple override so that the ALB will listen on port 8080 and forward traffic to the target
  listeners      = [{ port = 8080, protocol = "HTTP", action = { type = "forward" } }]
  container_port = 80
  container_definitions = [
    {
      name  = "nginx"
      image = "nginx:latest"
    }
  ]
}

module "http-to-https-redirect" {
  source = "../.."
  #source  = "USSBA/easy-fargate-service/aws"
  #version = "~> 6.7"

  family          = "ezfs-lstn-redirect"
  certificate_arn = "arn:aws:acm:cc-cccc-0:111111111111:certificate/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
  # Please note that when a ACM certificate ARN is not provided then HTTPS listeners will not be provisioned.
  listeners = [
    { port = 8080, protocol = "HTTP", action = { type = "redirect", port = 8443, protocol = "HTTPS" } },
    { port = 8443, protocol = "HTTPS", action = { type = "forward" } }
  ]
  container_port = 80
  container_definitions = [
    {
      name  = "nginx"
      image = "nginx:latest"
    }
  ]
}

module "http-to-https-redirect-status-code" {
  source = "../.."
  #source  = "USSBA/easy-fargate-service/aws"
  #version = "~> 6.7"

  family          = "ezfs-lstn-status"
  certificate_arn = "arn:aws:acm:cc-cccc-0:111111111111:certificate/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
  # A status code can be one of `HTTP_301` or `HTTP_302` and will default to `HTTP_301` if one is not provided.
  # It is also important to note that `host`, `path` and `query` redirect arguments are also supported by this module.
  # Please visit https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener#redirect regarding redirect configuraiton.
  listeners = [
    { port = 8080, protocol = "HTTP", action = { type = "redirect", port = 8443, protocol = "HTTPS", status_code = "HTTP_302" } },
    { port = 8443, protocol = "HTTPS", action = { type = "forward" } }
  ]
  container_port = 80
  container_definitions = [
    {
      name  = "nginx"
      image = "nginx:latest"
    }
  ]
}

module "http-to-https-redirect-ssl-policy" {
  source = "../.."
  #source  = "USSBA/easy-fargate-service/aws"
  #version = "~> 6.7"

  family          = "ezfs-lstn-ssl-pol"
  certificate_arn = "arn:aws:acm:cc-cccc-0:111111111111:certificate/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
  # By default the SSL policy is `ELBSecurityPolicy-TLS-1-1-2017-01` but can be overridden.
  # Please visit https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html for a listing of predefined security policies
  listeners = [
    { port = 8080, protocol = "HTTP", action = { type = "redirect", port = 8443, protocol = "HTTPS", status_code = "HTTP_302" } },
    { port = 8443, protocol = "HTTPS", ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01", action = { type = "forward" } },
  ]
  container_port = 80
  container_definitions = [
    {
      name  = "nginx"
      image = "nginx:latest"
    }
  ]
}

module "multiple_certs" {
  source = "../.."
  #source  = "USSBA/easy-fargate-service/aws"
  #version = "~> 6.7"

  family = "ezfs-lstn-multicert"
  certificate_arns = [
    "arn:aws:acm:cc-cccc-0:111111111111:certificate/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
    "arn:aws:acm:cc-cccc-0:111111111111:certificate/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
    "arn:aws:acm:cc-cccc-0:111111111111:certificate/cccccccc-cccc-cccc-cccc-cccccccccccc",
  ]
  #certificate_arns = [
  #  "arn:aws:acm:us-east-1:502235151991:certificate/7cd2a913-89c0-487b-8b6d-807286aceb11",
  #  "arn:aws:acm:us-east-1:502235151991:certificate/e1ce4a48-ba5b-446a-9dcf-bc2664378353",
  #  "arn:aws:acm:us-east-1:502235151991:certificate/6c8b6d24-185c-4ce2-9d81-e0498b791af6",
  #]
  # By default the SSL policy is `ELBSecurityPolicy-TLS-1-1-2017-01` but can be overridden.
  # Please visit https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html for a listing of predefined security policies
  listeners = [
    { port = 8080, protocol = "HTTP", action = { type = "redirect", port = 8443, protocol = "HTTPS", status_code = "HTTP_302" } },
    { port = 8443, protocol = "HTTPS", action = { type = "forward" } },
    { port = 9443, protocol = "HTTPS", action = { type = "forward" } },
    { port = 6443, protocol = "HTTPS", action = { type = "redirect", port = 8443, protocol = "HTTPS", status_code = "HTTP_302" } },
    { port = 7443, protocol = "HTTPS", action = { type = "redirect", port = 8443, protocol = "HTTPS", status_code = "HTTP_302" } },
  ]
  container_port = 80
  container_definitions = [
    {
      name  = "nginx"
      image = "nginx:latest"
    }
  ]
}
