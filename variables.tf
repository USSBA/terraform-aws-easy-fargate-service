# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Fargate task and service configuration
#

## Required
variable "family" {
  type        = string
  description = "Required; A unique name for the service family; Also used for naming various resources."
}

## Optional
variable "cluster_name" {
  type        = string
  description = "Optional; The name of the ECS cluster where the fargate service will run. Default is the default AWS cluster."
  default     = "default"
}
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
variable "efs_configs" {
  type = list(object({
    container_name = string
    file_system_id = string
    root_directory = string
    container_path = string
  }))
  description = "Optional; List of {container_name, file_system_id, root_directory, container_path} EFS mounts."
  default     = []
}
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
variable "container_port" {
  type        = number
  description = "Optional; the port the container listens on."
  default     = 80
}
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
variable "platform_version" {
  type        = string
  description = "Optional; The ECS backend platform version; Defaults to 1.4.0 so EFS is supported."
  default     = "1.4.0"
}
variable "task_policy_json" {
  type        = string
  description = "Optional; A JSON formated IAM policy providing the running container with permissions.  By default, no permissions granted."
  default     = ""
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Network and routing configuration
#

## Optional
variable "vpc_id" {
  type        = string
  description = "Optional; The VPC Id in which resources will be provisioned. Default is the default AWS vpc."
  default     = ""
}
variable "private_subnet_ids" {
  type        = list(string)
  description = "Optional; A set of subnet ID's that will be associated with the Farage service. By default the module will use the default vpc's public subnets."
  default     = []
}
variable "public_subnet_ids" {
  type        = list(string)
  description = "Optional; A set of subnet ID's that will be associated with the Application Load-balancer. By default the module will use the default vpc's public subnets."
  default     = []
}
variable "security_group_ids" {
  type        = list(string)
  description = "Optional; A set of additional security group ID's that will associated to the Fargate service network interface."
  default     = []
}
variable "certificate_arn" {
  type        = string
  description = "Optional; A certificate ARN being managed via ACM. If provided we will redirect 80 to 443 and serve on 443/https. Otherwise traffic will be served on 80/http."
  default     = ""
}
variable "hosted_zone_id" {
  type        = string
  description = "Optional; The hosted zone ID where the A record will be created. Required if `certificate_arn` is set."
  default     = ""
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
variable "use_cloudfront" {
  type        = bool
  description = "Optional; Creates a distribution with a default cache behavior. Default is `false`. If `true` and `service_fqdn` along with `hosted_zone_id` then the ALIAS record will point at this distrobution."
  default     = false
}
variable "cloudfront_blacklist_geo_restrictions" {
  type        = list(string)
  description = "Optional; List of alpha-2 country codes that will be blocked, all others will be allowed. Cannot be used with `whiltelist_geo_restrictions`."
  default     = []
}
variable "cloudfront_whitelist_geo_restrictions" {
  type        = list(string)
  description = "Optional; List of alpha-2 country codes that will be allowed, all others will be blocked. Cannot be used with `blacklist_geo_restrictions`."
  default     = []
}
variable "cloudfront_origin_custom_headers" {
  type        = list(object({ name = string, value = string }))
  description = "Optional; A custom set of header name/value pairs passed to the ALB from CloudFront. Typically used to pass a secret header to the ALB wich is validated by the regional WAF at the ALB."
  default     = []
}
variable "global_waf_acl_id" {
  type        = string
  description = "Optional; Global Web Application Firewall ID that will be applied to the CloudFront distribution."
  default     = ""
}
variable "regional_waf_acl_id" {
  type        = string
  description = "Optional; Regional Web Application Firewall ID that will be applied to the Application Load Balancer."
  default     = ""
}
variable "cloudfront_log_bucket_name" {
  type        = string
  description = "Optional: The S3 bucket name in which cloudfront logs will be delivered."
  default     = ""
}
variable "cloudfront_log_prefix" {
  type        = string
  description = "Optional; A text prefix prepended to the log file when it is delivered."
  default     = ""
}
variable "deregistration_delay" {
  type        = number
  description = "Optional; The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 20 seconds."
  default     = 20
}

variable "container_definitions" {
  #type        = any
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
