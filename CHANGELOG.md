# Changelog

## v3.0.0

* **BREAKING CHANGE:** `container_definition` has been DEPRICATES, use `container_definitions` map instead.
* **BREAKING CHANGE:** `efs_config` has been DEPRICATED, use `efs_configs` map instead.
* **BREAKING CHANGE:** `container_secrets` has been DEPRICATED, use `container_definitions[].secrets` map instead
* **BREAKING CHANGE:** `container_name` has been DEPRICATED, use `container_definitions[].name` instead.
* **BREAKING CHANGE:** `container_image` has been DEPRICATED, use `container_definitions[].image` instead.
* **BREAKING CHANGE:** `container_environment` has been DEPRICATED, use `container_definitions[].environment` instead.
* **BREAKING CHANGE:** `entrypoint_override` has been DEPRICATED, use `container_definitions[].entryPoint` instead.
* **BREAKING CHANGE:** `command_override` has been DEPRICATED, use `container_definitions[].command` instead.
* **FUNCTIONAL CHANGE:** `task_cpu` will now be divided evenly across containers unless explictly set by the container definition(s).
* **FUNCTIONAL CHANGE:** `task_memory` will now be divided evenly across containers unless explictly set by the container definition(s).

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
