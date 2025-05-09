# ECS
variable "family" {
  type        = string
  description = "Required; A unique name for the service family; Also used for naming various resources."
}
variable "cluster_name" {
  type        = string
  description = "Optional; The name of the ECS cluster where the fargate service will run. Default is the default AWS cluster."
  default     = "default"
}
variable "task_cpu" {
  type        = number
  description = "Optional; A fargate compliant container cpu value."
  default     = 256
}
variable "task_memory" {
  type        = number
  description = "Optional; A fargate compliant container memory value."
  default     = 512
}
variable "task_cpu_architecture" {
  type        = string
  description = "Optional; The task CPU architecture."
  default     = ""
}
variable "task_log_configuration_options" {
  type        = any
  description = "Optional; Used to add or override log configuration options of the ECS task definition."
  default     = {}
}
variable "platform_version" {
  type        = string
  description = "Optional; The ECS backend platform version; Defaults to LATEST which is platform version 1.4.0."
  default     = "LATEST"
}
variable "enable_execute_command" {
  type        = bool
  description = "Optional; Enable executing into running tasks using ECS Exec.  NOTE: Enabling this grants tasks ssmmessages and logs write permissions"
  default     = false
}

#
# WAF+SHIELD
#

variable "enable_shield_protection" {
  type        = bool
  description = "Optional; Enabled AWS Shield Protection targeting the Application Load-balancer."
  default     = false
}
variable "global_waf_acl" {
  type        = string
  description = "Optional; Global Web Application Firewall ID that will be applied to the CloudFront distribution. For wafv1, provide the WAF ID.  For WAFv2 provide the ARN."
  default     = ""
}
variable "regional_waf_acl" {
  type        = string
  description = "Optional; Regional Web Application Firewall identifier.  For wafv1, provide the WAF ID.  For WAFv2 provide the ARN."
  default     = ""
}

# Application Load Balancer
variable "alb_idle_timeout" {
  type        = number
  description = "Optional; Idle Timeout config for the ALB"
  default     = "60"
}
variable "deregistration_delay" {
  type        = number
  description = "Optional; The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 20 seconds."
  default     = 20
}
variable "listeners" {
  type        = any
  description = "Optional; The ALB listener configuration."
  default     = []
}
variable "listener_ssl_policy" {
  type        = string
  description = "Optional; The SSL policy name given to HTTPS listeners by default."
  default     = "ELBSecurityPolicy-TLS-1-1-2017-01"
}

variable "cloudfront_header" {
  type        = any
  description = "Optional; Custom header associated with CloudFront distribution origin requests. { key = \"header-name\", value = \"header-value\" }"
  default     = {}
}
variable "ipv6" {
  type        = bool
  description = "Optional; Enable the loadbalancer to accept IPv6 requests.  Only enable this if your VPC is configured to use IPv6.  Defaults to false"
  default     = false
}
variable "alb_sticky_duration" {
  type        = number
  description = "By default, sticky sessions are disabled. Once a number value is provided, sticky sessions are enabled, and the provided number is used to determine sticky session's duration in seconds"
  default     = 1
}
variable "alb_sticky_cookie_type" {
  type        = string
  description = "By default a cookie type of lb_cookie will be used. Only lb_cookie and app_cookie are supported."
  default     = "lb_cookie"
}
variable "alb_sticky_cookie_name" {
  type        = string
  description = "Applicable only when app_cookie is configured. The sticky session cookie domain name used when the `app_cookie` type is used."
  default     = ""
}
variable "alb_drop_invalid_header_fields" {
  type        = bool
  description = "Optional; Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is false. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. Only valid for Load Balancers of type application."
  default     = false
}

# Application Load Balancer Health Checks
variable "health_check_path" {
  type        = string
  description = "Optional; A relative path for the services health checker to hit. By default it will hit the root."
  default     = "/"
}
variable "health_check_healthy_threshold" {
  type        = number
  description = "Optional; The number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 10."
  default     = 10
}
variable "health_check_unhealthy_threshold" {
  type        = number
  description = "Optional; The number of consecutive health check failures required before considering the target unhealthy. Defaults to 10."
  default     = 10
}
variable "health_check_timeout" {
  type        = number
  description = "Optional; The amount of time, in seconds, during which no response means a failed health check. Defaults to 2"
  default     = 2
}
variable "health_check_interval" {
  type        = number
  description = "Optional; The approximate amount of time, in seconds, between health checks of an individual target. Defaults to 30"
  default     = 30
}
variable "health_check_matcher" {
  type        = string
  description = "Optional; The HTTP codes to use when checking for a successful response from a target. Defaults to '200-399'"
  default     = "200-399"
}

# Scaling
variable "desired_capacity" {
  type        = number
  description = "Optional; The desired number of containers running in the service. Default is 1."
  default     = 1
}
variable "max_capacity" {
  type        = number
  description = "Optional; The maximum number of containers running in the service. Default is same as `desired_capacity`."
  default     = -1
}
variable "min_capacity" {
  type        = number
  description = "Optional; The minimum number of containers running in the service. Default is same as `desired_capacity`."
  default     = -1
}
variable "scaling_metric" {
  type        = string
  description = "Optional; A type of target scaling. Needs to be either 'cpu' or 'memory'. Default is no scaling."
  default     = ""
}
variable "scaling_threshold" {
  type        = number
  description = "Optional; The percentage in which the scaling metric will trigger a scaling event. Default is no scaling."
  default     = -1
}
variable "scheduled_actions" {
  type = list(
    object({
      expression   = string
      min_capacity = number
      max_capacity = number
    })
  )
  description = "Optional; A list of scheduled actions [{expression = :string, min_capacity = :int, max_capacity = :int},...]; Expressions: [at(yyyy-mm-ddThh:mm:ss), rate(:value :unit), or cron(:minutes :hours :dayOfMonth :month :dayOfWeek :year)]; Default is []"
  default     = []
}
variable "scheduled_actions_timezone" {
  type        = string
  description = "Optional: The canonical name of the IANA time zone supported by Joda-Time;  Default is \"UTC\""
  default     = "UTC"
}

# Service Deployment
variable "deployment_maximum_percent" {
  type        = number
  description = "Optional; Upper limit on the number of running tasks that can be during a deployment. Default is 200."
  default     = 200
}
variable "deployment_minimum_healthy_percent" {
  type        = number
  description = "Optional; Lower limit percentage of tasks that must be reporting healthy during a deployment. Default is 100."
  default     = 100
}
variable "enable_deployment_rollbacks" {
  type        = bool
  description = "Optional; Enable application rollbacks, managed by ECS.  Defaults to false, but true is the recommended setting for production deployments"
  default     = false
}
variable "wait_for_steady_state" {
  type        = bool
  description = "Optional; Configure terraform to wait for ECS service to be deployed and stable before terraform finishes.  Note that Fargate deployments can take a remarkably long time to reach a steady state, and thus your terraform deployment times will increase by a few minutes.  Defaults to false"
  default     = false
}

# Logging
variable "log_group_name" {
  type        = string
  description = "Optional; The name of the log group. By default the `family` variable will be used."
  default     = ""
}
variable "log_group_retention_in_days" {
  type        = number
  description = "Optional; The number of days to retain the log group. By default logs will never expire."
  default     = 0
}
variable "log_group_region" {
  type        = string
  description = "Optional; The region where the log group exists. By default the current region will be used."
  default     = ""
}
variable "alb_log_bucket_name" {
  type        = string
  description = "Optional; The S3 bucket name to store the ALB access logs in."
  default     = ""
}
variable "alb_log_prefix" {
  type        = string
  description = "Optional; Prefix for each object created in ALB access log bucket."
  default     = ""
}

# Container
variable "container_port" {
  type        = number
  description = "Optional; the port the container listens on."
  default     = 80
}
variable "container_definitions" {
  description = "Container configuration in the form of a json-encoded list of maps. Required sub-fields are: 'name', 'image'; the rest will attempt to use sane defaults or can be overridden.  logConfiguration and mountPoints will be injected and overriden by other variables/resources, and the first "
  validation {
    condition     = can(var.container_definitions.*.name)
    error_message = "VALIDATION FAILURE: Every element of container_definitions must include a 'name' field."
  }
  validation {
    condition     = can(var.container_definitions.*.image)
    error_message = "VALIDATION FAILURE: Every element of container_definitions must include an 'image' field."
  }
  validation {
    condition     = can(var.container_definitions[0])
    error_message = "VALIDATION FAILURE: Variable container_definitions must be a list."
  }
  validation {
    condition     = can(var.container_definitions[0])
    error_message = "VALIDATION FAILURE: Variable container_definitions must be a list."
  }
  validation {
    error_message = "VALIDATION FAILURE: Variable container_definitions.*.portMappings must all be unique."
    condition     = length(distinct([for def in var.container_definitions : def.portMappings[0].containerPort if can(def.portMappings[0].containerPort)])) == length([for def in var.container_definitions : def.portMappings[0].containerPort if can(def.portMappings[0].containerPort)])
  }
}

# Elastic File System
variable "efs_configs" {
  type        = any
  description = "Optional; List of EFS configurations, see examples."
  default     = []
}

# non-persistent data volumes
variable "nonpersistent_volume_configs" {
  type = list(object({
    volume_name    = string
    container_name = string
    container_path = string
  }))
  description = "Optional; List of {volume_name, container_name, container_path} non-persistent volumes."
  default     = []
}

# Networking
variable "vpc_id" {
  type        = string
  description = "Required; A vpc-id"
}
variable "private_subnet_ids" {
  type        = list(string)
  description = "Required; A list of subnet-ids; Application load-balancer will be internal unless public_subnet_ids are provided."
}
variable "public_subnet_ids" {
  type        = list(string)
  description = "Optional; A list of subnet-ids; Application Load-balancer will be public facing."
  default     = []
}

# Security
variable "task_policy_json" {
  type        = string
  description = "Optional; A JSON formated IAM policy providing the running container with permissions.  By default, no permissions granted."
  default     = ""
}
variable "security_group_ids" {
  type        = list(string)
  description = "Required; A set of Security Group IDs to be associated with the Fargate service."
}
variable "alb_security_group_ids" {
  type        = list(string)
  description = "Required; A set of Security Group IDs to be associated with the Application Load-balancer."
}

# DNS
variable "hosted_zone_id" {
  type        = string
  description = "Optional; The hosted zone ID where the A record will be created. Required if `certificate_arn` is set."
  default     = ""
}
variable "certificate_arn" {
  type        = string
  description = "Optional; DEPRECATED, use certificate_arns. A certificate ARN being managed via ACM. If provided we will redirect 80 to 443 and serve on 443/https. Otherwise traffic will be served on 80/http."
  default     = ""
}
variable "certificate_arns" {
  type        = list(any)
  description = "Optional; A list of certificate ARNs being managed via ACM. If provided we will redirect 80 to 443 and serve on 443/https. Otherwise traffic will be served on 80/http."
  default     = []
}
variable "route53_allow_overwrite" {
  type        = bool
  description = "Optional; Set the 'allow_overwrite' property of the route53 record.  Defaults to `false`.  If `true`, there will be no `terraform import` necessary for pre-existing records."
  default     = false
}
variable "service_fqdn" {
  type        = string
  description = "Optional; Fully qualified domain name (www.example.com) you wish to use for your service. Must be valid against the ACM cert provided. Required if `certificate_arn` is set."
  default     = ""
}

# Tags
variable "tags" {
  type        = map(any)
  description = "Optional; Map of key-value tags to apply to all applicable resources"
  default     = {}
}
variable "tags_ecs" {
  type        = map(any)
  description = "Optional; Map of key-value tags to apply to the ecs resources"
  default     = {}
}
variable "tags_ecs_task_definition" {
  type        = map(any)
  description = "Optional; Map of key-value tags to apply to the ecs task definition"
  default     = {}
}
variable "tags_ecs_service" {
  type        = map(any)
  description = "Optional; Map of key-value tags to apply to the ecs service"
  default     = {}
}
variable "tags_ecs_service_enabled" {
  type        = bool
  description = "Optional; Enable/Disable all tags on ECS Service to avoid conflicts with Accounts/Clusters using the old ARN formats.  Defaults to true, adding tags to all ecs services"
  default     = true
}
variable "tags_alb" {
  type        = map(any)
  description = "Optional; Map of key-value tags to apply to the Application Load Balancer resources"
  default     = {}
}
variable "tags_alb_tg" {
  type        = map(any)
  description = "Optional; Map of key-value tags to apply to the Application Load Balancer Target Group"
  default     = {}
}
variable "tags_iam_role" {
  type        = map(any)
  description = "Optional; Map of key-value tags to apply to IAM Roles"
  default     = {}
}
variable "iam_role_path" {
  description = "Optional; Path attached to created IAM roles"
  type        = string
  default     = null
}
variable "iam_role_permissions_boundary" {
  description = "Optional; Permissions Boundary ARN attached to created IAM roles"
  type        = string
  default     = null
}
