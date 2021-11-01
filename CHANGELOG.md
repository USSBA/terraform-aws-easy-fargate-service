# Changelog

## v6.6.1
* **BUG FIX**
  * Fix situation where no waf is provided

## v6.6.0
* **NEW FEATURE**
  * Supports Regional (LoadBalancer) based WAFv2.
  * Adds `global_waf_acl` and `regional_waf_acl` vars
* **DEPRECATION NOTICE**
  * `regional_waf_acl_id` has been replaced with `regional_waf_acl`.  Eventually, `regional_waf_acl_id` will be removed.
     Until then, if both vars are populated, `regional_waf_acl` will be used.
  * `global_waf_acl_id` has been replaced with `global_waf_acl`.  Eventually, `global_waf_acl_id` will be removed.
     Until then, if both vars are populated, `global_waf_acl` will be used.


## v6.5.0
* **NEW FEATURE**
  * `nonpersistent_volume_configs` - List of {volume_name, container_name, container_path} non-persistent volumes

## v6.4.0

* **NEW FEATURES**
  * `lights_on_schedule_expr` - Expression that will trigger an event to restore max/min capacity back to configured settings
  * `lights_off_schedule_expr` - Expression that will trigger an event to set max/min capacity to zero
  * `schedule_timezone` - IANA Timezone in which to base `at` and `cron` schedule expressions

## v6.3.0

* **NEW FEATURES**
  * `ipv6` - Swap your ALB to use ipv6, and create an AAAA record (if needed)

## v6.2.0

* **NEW FEATURES**
  * `alb_idle_timeout` - Configure how long your alb will wait for your container to respond

## v6.1.0

* **NEW FEATURES**
  * `enable_deployment_rollbacks` - allows for rollbacks if a container fails to reach a steady state
  * `wait_for_steady_state` - Makes terraform wait until the ECS Service has fully deployed to a steady state before progressing
* **SECURITY UPDATES**
  * Bump SSL Policy on ALB Listeners

## v6.0.0
* **BREAKING CHANGES**
  * Switching to rule resources requires recreating the security group with a new name
* **NEW FEATURES**
  * `alb_security_group_ids` support providing your own security groups to the ALB
  * Fixed a "bug" preventing module names with underscores (due to ALB API nonsense)


## v5.0.1
* **BUGFIXES**
  * Fix security group rules when container port is non-80

## v5.0.0
* **BREAKING CHANGES**
  * Bump to aws provider >= 3.34
* **NEW FEATURES**
  * `enable_execute_command` support added to enable ssm'ing into a running fargate container

## v4.0.0

* **BREAKING CHANGES**
  * Added a `listeners` variable allowing developers to override default settings.
  * Prior listener resources will be destroyed as the namespace has changed and new listeners will be provisioned which may cause a short service interruption (&lt; 10 seconds). Older providers may require the TargetGroup to be replaced which may lead to a lengthier downtime.

* **NEW FEATURES**
* `deployment_maximum_percent` is now configurable.
* `deployment_minimum_healthy_percent` is now configurable.
* If the ALB is `internal` then the security groups will restrict traffic from the VPC cidr_block instead of from anywhere.

## v3.2.2

* If only `private_subnet_ids` are provided then the Fargate service and the ALB will be placed in them and will become an internal-facing load-balancer.
* If only `public_subnet_ids` are provided then the Fargate service and the ALB will be placed in them and will become a public-facing load-balancer.
* If neither `private_subnet_ids` and `public_subnet_ids` are provided then the default VPC subnets will be assumed and will become a public-facing load-balancer.
* If both `private_subnet_ids` and `public_subnet_ids` are provided then no change should occur.

## v3.2.1

* BUGFIX: Accounts not opted-in to new ARNs for ECS can't add ECS Service tags, adding flag to disable in such a case

## v3.2.0

* Adding in tagging framework, new example to show usage of all tags

## v3.1.0

* Adding configurable ALB healthcheck
* Adding in configurable deregistration delay

## v3.0.0

* **BREAKING CONFIGURATION CHANGES:**
  * `container_definition` has been REMOVED, use `container_definitions` list of maps instead.
  * `efs_config` has been REMOVED, use `efs_configs` list of maps instead.
  * `container_secrets` has been REMOVED, use `container_definitions[].secrets` map instead
  * `container_name` has been REMOVED, use `container_definitions[].name` instead.
  * `container_image` has been REMOVED, use `container_definitions[].image` instead.
  * `container_environment` has been REMOVED, use `container_definitions[].environment` instead.
  * `entrypoint_override` has been REMOVED, use `container_definitions[].entryPoint` instead.
  * `command_override` has been REMOVED, use `container_definitions[].command` instead.
  * `log_group_stream_prefix` has been REMOVED, and the `container_definition[].name` will instead be used for all `log_group_stream_prefixes`
* **RESOURCE REPLACING CHANGES:**
  * Target Groups will now add a randomized suffix to facilitate easier replacement when dependent configuration changes
    * This causes all TargetGroups (and dependent resources) to be replaced.
* `task_cpu` will now be divided evenly across containers unless explicitly set by the container definition(s).
* `task_memory` will now be divided evenly across containers unless explicitly set by the container definition(s).

## v2.4.0

* Adding `efs_configs` to allow multiple EFS mounts.  `efs_config` will function the same as before, but is considered deprecated.
  * Note, this will trigger a new Task Definition to be created due to a change in the way volumes/mounts are named

## v2.3.1

* **BUGFIX** CloudFront origin config was broken
* **BUGFIX** CloudFront geo_restriction config was broken with no restrictions

## v2.3.0

* Switching 'no-value' from null to empty string, empty list, or negative number to prevent Terraform Registry from showing optional variables as required

## v2.2.1

* Updated documentation for clarity and ease of use, added code validation to CircleCI config, and MD linter to precommit config

## v2.2.0

* Added support for optional CloudFront distribution

## v2.1.0

* Add `route53_allow_overwrite` option for route53 config

## v2.0.1

* Output aws_ecs_service.fargate

## v2.0.0

* **Terraform 13**

## v1.0.0

* Initial Release
