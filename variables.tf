# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Fargate task and service configuration
#

## Required
variable "family" {
  type        = string
  description = "Required; A unique name for the service family; Also used for naming various resources."
}
variable "container_image" {
  type        = string
  description = "Required; A fully qualified docker image repository name and tag."
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
  default     = null
}
variable "min_capacity" {
  type        = number
  description = "Optional; The minimum number of containers running in the service. Default is same as `desired_capacity`."
  default     = null
}
variable "scaling_metric" {
  type        = string
  description = "Optional; A type of target scaling. Needs to be either cpu or memory. Default is null."
  default     = null
}
variable "scaling_threshold" {
  type        = number
  description = "Optional; The percentage in which the scaling metric will trigger a scaling event. Default is null."
  default     = null
}
variable "efs_config" {
  type = object({
    file_system_id = string
    root_directory = string
    container_path = string
  })
  description = "Optional; The EFS id, root directory, and path. The module currently supports only one mount."
  default     = null
}
variable "log_group_name" {
  type        = string
  description = "Optional; The name of the log group. By default the `family` variable will be used."
  default     = null
}
variable "log_group_stream_prefix" {
  type        = string
  description = "Optional; The name of the log group stream prefix. By default this will be `container`."
  default     = "container"
}
variable "log_group_retention_in_days" {
  type        = number
  description = "Optional; The number of days to retain the log group. By default logs will never expire."
  default     = 0
}
variable "log_group_region" {
  type        = string
  description = "Optional; The region where the log group exists. By default the current region will be used."
  default     = null
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
variable "container_environment" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Optional; Environment variables to be passed in to the container."
  default     = []
}
variable "container_secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "Optional; ECS Task Secrets to be passed in to the container and have permissions granted to read."
  default     = []
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
variable "platform_version" {
  type        = string
  description = "Optional; The ECS backend platform version; Defaults to 1.4.0 so EFS is supported."
  default     = "1.4.0"
}
variable "entrypoint_override" {
  type        = list(string)
  description = "Optional; Your Docker entrypoint command. Default is the `ENTRYPOINT` directive from the Docker image."
  default     = null
}
variable "command_override" {
  type        = list(string)
  description = "Optional; Your Docker command. Default is the `CMD` directive from the Docker image."
  default     = null
}
variable "task_policy_json" {
  type        = string
  description = "Optional; A JSON formated IAM policy providing the running container with permissions."
  default     = null
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Network and routing configuration
#

## Optional
variable "vpc_id" {
  type        = string
  description = "Optional; The VPC Id in which resources will be provisioned. Default is the default AWS vpc."
  default     = null
}
variable "private_subnet_ids" {
  type        = list(string)
  description = "Optional; A set of subnet ID's that will be associated with the Farage service. By default the module will use the default vpc's public subnets."
  default     = null
}
variable "public_subnet_ids" {
  type        = list(string)
  description = "Optional; A set of subnet ID's that will be associated with the Application Load-balancer. By default the module will use the default vpc's public subnets."
  default     = null
}
variable "security_group_ids" {
  type        = list(string)
  description = "Optional; A set of additional security group ID's that will associated to the Fargate service network interface."
  default     = []
}
variable "certificate_arn" {
  type        = string
  description = "Optional; A certificate ARN being managed via ACM. If provided we will redirect 80 to 443 and serve on 443/https. Otherwise traffic will be served on 80/http."
  default     = null
}
variable "hosted_zone_id" {
  type        = string
  description = "Optional; The hosted zone ID where the A record will be created. Required if `certificate_arn` and `service_fqdn` is set."
  default     = null
}
variable "route53_allow_overwrite" {
  type        = bool
  description = "Optional; Set the 'allow_overwrite' property of the route53 record.  Defaults to `false`.  If `true`, there will be no `terraform import` necessary for pre-existing records."
  default     = false
}
variable "service_fqdn" {
  type        = string
  description = "Optional; Fully qualified domain name (www.example.com) you wish to use for your service. Must be valid against the ACM cert provided. Required if `certificate_arn` and `hosted_zone_id` is set."
  default     = null
}
variable "alb_log_bucket_name" {
  type        = string
  description = "Optional; The S3 bucket name to store the ALB access logs in. Default is null."
  default     = null
}
variable "alb_log_prefix" {
  type        = string
  description = "Optional; Prefix for each object created in ALB access log bucket. Default is null."
  default     = null
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
