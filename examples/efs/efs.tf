# Default VPC, for mount targets
data "aws_vpc" "default" {
  default = true
}
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group" "efs" {
  description = "easy-fargate-efs EFS"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_efs_file_system" "efs-one" {
  creation_token = "my-efs-one"

  tags = {
    Name = "my-efs-one"
  }
}

resource "aws_efs_mount_target" "efs-one" {
  for_each        = data.aws_subnet_ids.default.ids
  file_system_id  = aws_efs_file_system.efs-one.id
  subnet_id       = each.key
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_file_system" "efs-two" {
  creation_token = "my-efs-two"

  tags = {
    Name = "my-efs-two"
  }
}

resource "aws_efs_mount_target" "efs-two" {
  for_each        = data.aws_subnet_ids.default.ids
  file_system_id  = aws_efs_file_system.efs-two.id
  subnet_id       = each.key
  security_groups = [aws_security_group.efs.id]
}
