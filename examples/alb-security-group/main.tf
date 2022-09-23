##
## Create a security group that is only accessible by a single IP address
##
data "aws_vpc" "default" {
  default = true
}
variable "dev_ip" {
  description = "This IP address is the only one that will be able to access fargate service.  If you want to use the internet-facing IP of this computer, enter 'me'"
  type        = string
}
data "http" "dev_ip" {
  count = var.dev_ip == "me" ? 1 : 0
  url   = "https://checkip.amazonaws.com/"
}
locals {
  dev_ip = chomp(try(data.http.dev_ip[0].body, var.dev_ip))
}
resource "aws_security_group" "alb_sg" {
  name        = "easy_fargate_alb_sg_dev_ip"
  description = "Allow Developer IP to access to service"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "TLS from Developer"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${local.dev_ip}/32"]
  }
  ingress {
    description = "HTTP from Developer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${local.dev_ip}/32"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

##
## Easy Fargate Service that overrides the default ALB Security Group
##
module "easy_fargate_alb_sg" {
  #source  = "USSBA/easy-fargate-service/aws"
  #version = "~> 6.0"
  source = "../../"

  family = "easy_fargate_alb_sg"
  container_definitions = [
    {
      name  = "nginx"
      image = "nginx:latest"
    }
  ]

  tags = {
    ManagedBy = "Terraform"
  }
  alb_security_group_ids         = [aws_security_group.alb_sg.id]
  alb_idle_timeout               = 300
  alb_drop_invalid_header_fields = true
  wait_for_steady_state          = true
}
output "dev_connection_information" {
  value = <<-EOT

    ****
    **** Connect to fargate service: http://${module.easy_fargate_alb_sg.alb_dns}/ from IP address: ${local.dev_ip}
    ****
    EOT
}
