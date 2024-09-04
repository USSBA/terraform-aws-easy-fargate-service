# Changelog

## v11.2.0
* **UPDATE**
  * Module will now require Terraform version ~> v1.9 with AWS provider ~> 5.0

## v11.1.2

* **UPDATE**
  * Added new variable `cloudfront_whitelist_forwarded_headers` allowing the engineer to add additional CloudFront headers to the whitelist.

## v11.1.1
* **UPDATE**
  * Added new variable `task_log_configuration_options` allowing the engineer to add or override task definition log configuration options.
  * [Using the awslogs log driver](https://docs.aws.amazon.com/AmazonECS/latest/userguide/using_awslogs.html)
  * Use Case:
    * Set the logging **mode** to `non-blocking`
    * Alter the `awslogs-stream-prefix` if the prefix issued by this module is undesirable.

## v11.0.1
* **BUG FIX**
  * Resolved an EFS mount point issue when using an `access_point_id` in the `authorization_config` instead of the `root_directory` preventing the
    generated MD5 hash, used for naming the volume, from being unique.

## v11.0.0
* **UPDATE**
  * Fixed an issue with the ALB IPv6 ingress security group rule assignments.
  * Adjustments were made to ingress and egress security group rules and are now provisioned as separate resources.
  * Please use the following script for aide in resolving changes to the state.

<pre>
FAMILY_NAME='example-service'
ALB_SGID=`aws ec2 describe-security-groups --query "SecurityGroups[?GroupName == '${FAMILY_NAME}-alb'].GroupId" --output text`
SVC_SGID=`aws ec2 describe-security-groups --query "SecurityGroups[?GroupName == '${FAMILY_NAME}-svc-sg'].GroupId" --output text`
terraform import 'module.dsbs.aws_security_group_rule.alb_egress' "${ALB_SGID}_egress_all_0_0_0.0.0.0/0"
terraform import 'module.dsbs.aws_security_group_rule.fargate_egress' "${SVC_SGID}_egress_all_0_0_0.0.0.0/0"
# If for some reason you receive the following output after an apply when IPv6 == true.
# Please import the IPv6 rule because it will have been created during the terraform apply but was never record in the state for some reason.
#   Error: [WARN] A duplicate Security Group rule was found on (sg-00000000000000000). etc....
terraform import 'module.dsbs.aws_security_group_rule.alb_egress_ipv6[0]' "${ALB_SGID}_egress_all_0_0_::/0"
</pre>

## v10.1.2
* **UPDATE**
  * Removed log mode. Seeing inconsistencies with provider.

## v10.1.1
* **BUG FIX**
  * Added a `merge()` to aws log driver `mode`.
  * AWS Log Driver mode supports `blocking` and `non-blocking`, however, when defaulting to `blocking` Terraform is throwing the following error `ClientException: The blocking mode specified for log configuration options is invalid`. This will now only set the `mode: "non-blocking"` if `var.log_group_mode` is set to `non-blocking`.

## v10.1.0

* **UPDATE**
  * Added `log_group_mode` variable with default of `blocking`. Modes supported are `blocking` and `non-blocking`.

## v10.0.0

* **UPDATE**
  * Updated to support Terraform provider `~> 5.0`

## v9.3.3

* **UPDATE**
  * Updated the ECS Platform Version to `LATEST`. LATEST uses ECS Platform 1.4.0.

## v9.3.2
* **UPDATE**
  * Added the `alb_sticky_cookie_type` variable with default of `lb_cookie` for backwards compatibility.

* **FIX**
  * Problem - When transitioning from an `app_cookie` to an `lb_cookie` AWS seems persist the `cookie_name` which is causing Terraform to detect a change on every plan evaluation even though the `cookie_name` is irrelevant.
  * Solution - The ALB sticky cookie type is no longer based on the `alb_sticky_cookie_name` variable and can be passed to the module regardless of the cookie type. During a transition from `app_cookie` to `lb_cookie` you may need to keep the cookie name in place to prevent Terraform from detecting a state change.

## v9.3.1
  **UPDATE**
  * Modified description of ALB sticky session variables.

## v9.3.0
* **NEW FEATURE**
  * Adds `enable_shield_protection` to allow enabling this security feature to help add protection to Application Load Balancers.

## v9.2.0
* **NEW FEATURE**
  * Adds `alb_drop_invalid_header_fields` to allow enabling this security feature of the ALB

## v9.1.0
* **NEW FEATURE**
  * Adds `iam_role_path` and `iam_role_permissions_boundary` for additional IAM role configuration

## v9.0.0
* **UPDATE**
  * Added `authorization_config` to the `efs_configs` variable
  * Changed `efs_configs` to `any` instead of `list(object)`

## v8.0.0
* **UPDATE**
  * Updated aws provider version from `>= 3.69, < 4.0` to `~> 4.0`
  * Updated Terraform version from `>= 0.13` to `~> 1.0`
  * Replaced deprecated `data "aws_subnet_ids"` with `data "aws_subnets"`

## v7.1.0
* **NEW FEATURE**
  * Adds a new variable called `cloudfront_header` that when provided changes the `default_action` of the 443 listener
    to a fixed response of `403 Access denied` and places a rule at priority 1 that validates the header before permitting
    traffic to the origin

## v7.0.1
* **UPDATE**
  * Adds new module configuration variable `task_cpu_architecture`

## v7.0.0
* **NEW FEATURE**
  * Adds `scheduled_actions` allowing any number of actions to be configured
    [{expression = "cron(0 12 * * ? *), max_capacity = 200, min_capacity = 25"},...]
  * Renamed variable `schedule_timezone` to `scheduled_actions_timezone`
  **RETIRED FEATURE**
  * The lights on/off feature has been removed entirely

## v6.9.0
* **UPDATE FEATURE**
  * Adds `lights_off_desired_capacity` in order to keep a set number of containers running durings this period of time rather then a static zero

## v6.8.0
* **NEW FEATURE**
  * Now supports load balancer sticky sessions
  * Adds `alb_sticky_duration` and `alb_sticky_cookie_name` in support of this

## v6.7.0
* **NEW FEATURE**
  * Now supports multiple certificates for https listeners
  * Adds `certificate_arns` var in support of this
  * Deprecates `certificate_arn` var

## v6.6.1
* **BUG FIX**
  * Fix situation where no waf is provided

## v6.6.0
* **NEW FEATURE**
  * Supports Regional (LoadBalancer) based WAFv2.
  * Adds `global_waf_acl` and `regional_waf_acl` vars
* **DEPRECATION NOTICE**
  * `regional_waf_acl_id` has been replaced with `regional_waf_acl`.  Eventually, `regional_waf_acl_id` will be removed
     Until then, if both vars are populated, `regional_waf_acl` will be used
  * `global_waf_acl_id` has been replaced with `global_waf_acl`.  Eventually, `global_waf_acl_id` will be removed
     Until then, if both vars are populated, `global_waf_acl` will be used


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
