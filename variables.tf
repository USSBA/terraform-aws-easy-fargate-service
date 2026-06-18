# ECS
variable "family" {
  type        = string
  description = "Required; A unique name for the service family. Also used for naming various resources."
}

variable "container_definitions" {
  type        = any
  description = "Required; Container configuration as a list of maps. Must include 'name' and 'image'. Other fields will use defaults or be overridden."

  validation {
    condition     = length(var.container_definitions) > 0
    error_message = "VALIDATION FAILURE: Variable container_definitions must contain at least one container definition."
  }

  validation {
    condition = alltrue([
      for container_definition in var.container_definitions : can(container_definition.name)
    ])
    error_message = "VALIDATION FAILURE: Every element of container_definitions must include a 'name' field."
  }

  validation {
    condition = alltrue([
      for container_definition in var.container_definitions : can(container_definition.image)
    ])
    error_message = "VALIDATION FAILURE: Every element of container_definitions must include an 'image' field."
  }

  validation {
    error_message = "VALIDATION FAILURE: Variable container_definitions.*.portMappings must all be unique."
    condition     = length(distinct([for def in var.container_definitions : def.portMappings[0].containerPort if can(def.portMappings[0].containerPort)])) == length([for def in var.container_definitions : def.portMappings[0].containerPort if can(def.portMappings[0].containerPort)])
  }
}

variable "container_port" {
  type        = number
  description = "Optional; The port the container listens on."
  default     = 80
}

# ECS/Fargate Settings
variable "cluster_name" {
  type        = string
  description = "Optional; The name of the ECS cluster where the Fargate service will run. Defaults to the default AWS cluster."
  default     = "default"
}

variable "task_cpu" {
  type        = number
  description = "Optional; A Fargate-compliant container CPU value."
  default     = 256
}

variable "task_memory" {
  type        = number
  description = "Optional; A Fargate-compliant container memory value."
  default     = 512
}

variable "task_cpu_architecture" {
  type        = string
  description = "Optional; The task CPU architecture."
  default     = ""
}

variable "enable_execute_command" {
  type        = bool
  description = "Optional; Enable executing into running tasks using ECS Exec. NOTE: Enabling this grants tasks ssmmessages and logs write permissions."
  default     = false
}

variable "platform_version" {
  type        = string
  description = "Optional; The ECS backend platform version. Defaults to LATEST, which is platform version 1.4.0."
  default     = "LATEST"
}

variable "task_log_configuration_options" {
  type        = any
  description = "Optional; Used to add or override log configuration options of the ECS task definition."
  default     = {}
}

# Scaling
variable "desired_capacity" {
  type        = number
  description = "Optional; Desired number of containers running in the service. Defaults to 1."
  default     = 1
}

variable "min_capacity" {
  type        = number
  description = "Optional; Minimum number of containers running in the service. Defaults to same as 'desired_capacity'."
  default     = -1
}

variable "max_capacity" {
  type        = number
  description = "Optional; Maximum number of containers running in the service. Defaults to same as 'desired_capacity'."
  default     = -1
}

variable "scaling_metric" {
  type        = string
  description = "Optional; Target scaling type. Must be 'cpu' or 'memory'. Defaults to no scaling."
  default     = ""
}

variable "scaling_threshold" {
  type        = number
  description = "Optional; Percentage threshold for the scaling metric to trigger scaling. Defaults to no scaling."
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
  description = "Optional; Canonical IANA timezone name supported by Joda-Time. Defaults to 'UTC'."
  default     = "UTC"
}

# Service Deployment
variable "deployment_maximum_percent" {
  type        = number
  description = "Optional; Upper limit on the number of running tasks during deployment. Defaults to 200."
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  description = "Optional; Lower limit percentage of tasks that must be healthy during deployment. Defaults to 100."
  default     = 100
}

variable "enable_deployment_rollbacks" {
  type        = bool
  description = "Optional; Enable application rollbacks managed by ECS. Defaults to false. Recommended: true for production."
  default     = false
}

variable "wait_for_steady_state" {
  type        = bool
  description = "Optional; Instruct Terraform to wait for ECS service deployment stability before finishing. Defaults to false."
  default     = false
}

# Load Balancer (ALB)
variable "listeners" {
  type        = any
  description = "Optional; The ALB listener configuration."
  default     = []
}

variable "listener_ssl_policy" {
  type        = string
  description = "Optional; The SSL policy name given to HTTPS listeners."
  default     = "ELBSecurityPolicy-TLS-1-1-2017-01"
}

variable "alb_idle_timeout" {
  type        = number
  description = "Optional; Idle timeout configuration for the ALB."
  default     = 60
}

variable "deregistration_delay" {
  type        = number
  description = "Optional; Time for Elastic Load Balancing to wait before changing a deregistering target's state from draining to unused. Range: 0–3600 seconds. Defaults to 20 seconds."
  default     = 20
}

variable "alb_sticky_duration" {
  type        = number
  description = "Optional; Enables sticky sessions and defines their duration in seconds. Defaults to 1."
  default     = 1
}

variable "alb_sticky_cookie_type" {
  type        = string
  description = "Optional; Type of cookie used for sticky sessions. Valid values are 'lb_cookie' and 'app_cookie'. Defaults to 'lb_cookie'."
  default     = "lb_cookie"
}

variable "alb_sticky_cookie_name" {
  type        = string
  description = "Optional; Cookie name used for sticky sessions when 'app_cookie' is configured."
  default     = ""
}

variable "alb_drop_invalid_header_fields" {
  type        = bool
  description = "Optional; Indicates whether the ALB removes invalid HTTP headers (true) or routes them to targets (false). Defaults to false."
  default     = false
}

variable "ipv6" {
  type        = bool
  description = "Optional; Enable the load balancer to accept IPv6 requests. Only enable if your VPC supports IPv6. Defaults to false."
  default     = false
}

# Health Checks
variable "health_check_path" {
  type        = string
  description = "Optional; Relative path for the service's health checker to hit. Defaults to '/'."
  default     = "/"
}

variable "health_check_healthy_threshold" {
  type        = number
  description = "Optional; Number of consecutive health check successes required before considering a target healthy. Defaults to 10."
  default     = 10
}

variable "health_check_unhealthy_threshold" {
  type        = number
  description = "Optional; Number of consecutive health check failures required before considering a target unhealthy. Defaults to 10."
  default     = 10
}

variable "health_check_timeout" {
  type        = number
  description = "Optional; Time in seconds with no response to consider a failed health check. Defaults to 2."
  default     = 2
}

variable "health_check_interval" {
  type        = number
  description = "Optional; Time in seconds between health checks of an individual target. Defaults to 30."
  default     = 30
}

variable "health_check_matcher" {
  type        = string
  description = "Optional; HTTP codes used to determine a successful health check response. Defaults to '200-399'."
  default     = "200-399"
}

# Logging
variable "log_group_name" {
  type        = string
  description = "Optional; Name of the log group. Defaults to the 'family' variable."
  default     = ""
}

variable "log_group_retention_in_days" {
  type        = number
  description = "Optional; Number of days to retain the log group. Defaults to never expire."
  default     = 0
}

variable "log_group_region" {
  type        = string
  description = "Optional; Region where the log group exists. Defaults to the current region."
  default     = ""
}

variable "alb_log_bucket_name" {
  type        = string
  description = "Optional; S3 bucket name to store ALB access logs."
  default     = ""
}

variable "alb_log_prefix" {
  type        = string
  description = "Optional; Prefix for each object in ALB access log bucket."
  default     = ""
}

# Networking
variable "vpc_id" {
  type        = string
  description = "Required; A VPC ID."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Required; List of subnet IDs. The ALB will be internal unless public_subnet_ids are provided."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Optional; List of subnet IDs. The ALB will be public-facing."
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "Required; Set of Security Group IDs for the Fargate service."
}

variable "alb_security_group_ids" {
  type        = list(string)
  description = "Required; Set of Security Group IDs for the Application Load Balancer."
}

# Volumes
variable "efs_configs" {
  type        = any
  description = "Optional; List of EFS configurations. See examples."
  default     = []
}

variable "nonpersistent_volume_configs" {
  type = list(object({
    volume_name    = string
    container_name = string
    container_path = string
  }))

  description = "Optional; List of non-persistent volumes in format: {volume_name, container_name, container_path}."
  default     = []
}

# IAM/Security
variable "task_policy_json" {
  type        = string
  description = "Optional; JSON-formatted IAM policy granting additional permissions to the ECS task role. Defaults to no additional permissions."
  default     = ""
}

variable "execution_policy_json" {
  type        = string
  description = "Optional; JSON-formatted IAM policy granting additional permissions to the ECS task execution role. Defaults to no additional permissions."
  default     = ""
}

variable "iam_role_path" {
  description = "Optional; Path attached to created IAM roles."
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "Optional; Permissions boundary ARN attached to created IAM roles."
  type        = string
  default     = null
}

# WAF and Shield
variable "enable_shield_protection" {
  type        = bool
  description = "Optional; Enables AWS Shield Protection targeting the Application Load Balancer."
  default     = false
}

variable "global_waf_acl" {
  type        = string
  description = "Optional; Global Web Application Firewall ID to apply to the CloudFront distribution. For WAFv1, provide the WAF ID. For WAFv2, provide the ARN."
  default     = ""
}

variable "regional_waf_acl" {
  type        = string
  description = "Optional; ARN of the regional Web Application Firewall (WAFv2) to associate with the ALB. WAFv1 is not supported."
  default     = ""
}

# DNS and HTTPS
variable "hosted_zone_id" {
  type        = string
  description = "Optional; Hosted zone ID for the A record. Required if 'certificate_arn' is set."
  default     = ""
}

variable "service_fqdn" {
  type        = string
  description = "Optional; Fully qualified domain name for your service. Must match ACM certificate. Required if 'certificate_arn' is set."
  default     = ""
}

variable "certificate_arn" {
  type        = string
  description = "Optional; DEPRECATED. Use 'certificate_arns'. ACM certificate ARN for HTTPS traffic."
  default     = ""
}

variable "certificate_arns" {
  type        = list(any)
  description = "Optional; List of ACM certificate ARNs. Enables HTTPS and redirects HTTP."
  default     = []
}

variable "route53_allow_overwrite" {
  type        = bool
  description = "Optional; Sets 'allow_overwrite' for Route53 record. Defaults to false."
  default     = false
}

variable "cloudfront_header" {
  type        = any
  description = "Optional; Custom header associated with CloudFront distribution origin requests. Format: { key = \"header-name\", value = \"header-value\" }."
  default     = {}
}

# Tags
variable "tags" {
  type        = map(any)
  description = "Optional; Key-value map of tags for all resources."
  default     = {}
}

variable "tags_ecs" {
  type        = map(any)
  description = "Optional; Key-value map of tags for ECS resources."
  default     = {}
}

variable "tags_ecs_service" {
  type        = map(any)
  description = "Optional; Key-value map of tags for ECS services."
  default     = {}
}

variable "tags_ecs_service_enabled" {
  type        = bool
  description = "Optional; Enable/disable tags on ECS Service to avoid conflicts with legacy ARN formats. Defaults to true."
  default     = true
}

variable "tags_ecs_task_definition" {
  type        = map(any)
  description = "Optional; Key-value map of tags for ECS task definitions."
  default     = {}
}

variable "tags_alb" {
  type        = map(any)
  description = "Optional; Key-value map of tags for the ALB."
  default     = {}
}

variable "tags_alb_tg" {
  type        = map(any)
  description = "Optional; Key-value map of tags for the ALB target group."
  default     = {}
}

variable "tags_iam_role" {
  type        = map(any)
  description = "Optional; Key-value map of tags for IAM roles."
  default     = {}
}