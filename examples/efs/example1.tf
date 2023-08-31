# A single volume with a single mountpoint
module "example" {
  #...
  efs_configs = flatten([
    {
      container_name = "foo"
      file_system_id = aws_efs_file_system.efs.id
      root_directory = "/private"
      container_path = "/var/www/html/private"
    },
  ])
  #...
}

resource "aws_security_group_rule" "allow_fargate_into_efs" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = module.example.security_group_id
}
