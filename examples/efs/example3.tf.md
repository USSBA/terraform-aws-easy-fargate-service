# Using the authorization_config.access_point_id instead of the root_directory with a single EFS volume.
module "example" {
  #...
  efs_configs = flatten([
    {
      container_name = "foo"
      file_system_id = aws_efs_file_system.efs.id
      # Note: root_directory is not necessary when access_point_id is given
      container_path = "/var/www/html/foo"
      authorization_config = {
        access_point_id = aws_efs_access_point.foo.id
        iam             = "DISABLED"
      }
    },
    {
      container_name = "bar"
      file_system_id = aws_efs_file_system.efs.id
      # Note: root_directory is not necessary when access_point_id is given
      container_path = "/var/www/html/bar"
      authorization_config = {
        access_point_id = aws_efs_access_point.bar.id
        iam             = "DISABLED"
      }
    },
  ])
  #...
}

# permit the service to mount EFS using port 2049
resource "aws_security_group_rule" "allow_fargate_into_efs" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = module.example.security_group_id
}
