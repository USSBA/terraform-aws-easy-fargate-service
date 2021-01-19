# Changelog

## v3.0.0

* **BREAKING CHANGES:**
  * `container_definition` has been REMOVED, use `container_definitions` list of maps instead.
  * `efs_config` has been REMOVED, use `efs_configs` list of maps instead.
  * `container_secrets` has been REMOVED, use `container_definitions[].secrets` map instead
  * `container_name` has been REMOVED, use `container_definitions[].name` instead.
  * `container_image` has been REMOVED, use `container_definitions[].image` instead.
  * `container_environment` has been REMOVED, use `container_definitions[].environment` instead.
  * `entrypoint_override` has been REMOVED, use `container_definitions[].entryPoint` instead.
  * `command_override` has been REMOVED, use `container_definitions[].command` instead.
* `task_cpu` will now be divided evenly across containers unless explictly set by the container definition(s).
* `task_memory` will now be divided evenly across containers unless explictly set by the container definition(s).

## v2.4.0

* Adding `efs_configs` to allow multiple EFS mounts.  `efs_config` will function the same as before, but is considered deprecated.
  * Note, this will trigger a new Task Definition to be created due to a change in the way volumes/mounts are named

## v2.3.1

* **BUGFIX** CloudFront origin config was broken
* **BUGFIX** CloudFront geo_restriction config was broken with no restrictions

## v2.3.0

* Switching 'no-value' from null to empty string, empty list, or negative number to prevent Terraform Registry from showing optional variables as requred

## v2.2.1

* Updated documentation for clarity and ease of use, added code validation to CircleCI config, and MD linter to precommit config

## v2.2.0

* Added support for optional CloudFront distributon

## v2.1.0

* Add `route53_allow_overwrite` option for route53 config

## v2.0.1

* Output aws_ecs_service.fargate

## v2.0.0

* **Terraform 13**

## v1.0.0

* Initial Release
