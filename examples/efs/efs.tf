# Default VPC, for mount targets
data "aws_vpc" "default" {
  default = true
  #id = "vpc-12341234123412341"
}
data "aws_subnets" "default" {
 filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  #filter {
  #  name = "tag:Name"
  #  values = ["*private*"]
  #}
}

resource "aws_security_group" "efs" {
  description = "easy-fargate-efs EFS"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_efs_file_system" "efs-one" {
  creation_token = "my-efs-one"
  encrypted      = true

  tags = {
    Name = "my-efs-one"
  }
}

resource "aws_efs_mount_target" "efs-one" {
  for_each        = toset(data.aws_subnets.default.ids)
  file_system_id  = aws_efs_file_system.efs-one.id
  subnet_id       = each.key
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_file_system" "efs-two" {
  creation_token = "my-efs-two"
  encrypted      = true

  tags = {
    Name = "my-efs-two"
  }
}

resource "aws_efs_mount_target" "efs-two" {
  for_each        = toset(data.aws_subnets.default.ids)
  file_system_id  = aws_efs_file_system.efs-two.id
  subnet_id       = each.key
  security_groups = [aws_security_group.efs.id]
}
