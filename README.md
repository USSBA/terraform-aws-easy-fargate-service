# terraform-aws-easy-fargate-service

Do you have a single container web service that needs to be stood up in a hurry? Does your boss need you to deploy this Wordpress site yesterday? We got you covered. With `easy-fargate-service` you can quickly and simply deploy a service using AWS Fargate.

Features:

* Sane Defaults
* Load balanced out of the box
* Can optionally provision a CloudFront distribution for your application
* Configurable scaling
* Looks up Default VPC/Subnets/etc unless told otherwise
* Supports EFS and WAF
* Supports multiple containers

## Usage

### Prerequisites

* VPC and ECS Cluster (AWS default will do!)
* A docker image
* An ACM cert (only a prerequisite if you want to run the service over HTTPS)

### Variables

#### Required

* `family` - A unique name for the service family; Also used for naming various resources.
* `container_definitions` - List of `{name, image}` at minimum.  If using more than 1 container, must also define `portMappings = [{ containerPort = <port> }]` on the container to be reached by the load balancer.  See [AWS documentation](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html) for more the complete list of settings.  See [the examples directory](./examples) for different implementation examples.

#### Optional

##### Fargate Task and Service Configuration

* `cluster_name` - The name of the ECS cluster where the Fargate service will run. Default is the default AWS cluster.
* `desired_capacity` - The desired number of containers running in the service. Default is `1`.
* `max_capacity` - The maximum number of containers running in the service. Default is same as `desired_capacity`.
* `min_capacity` - The minimum number of containers running in the service. Default is same as `desired_capacity`.
* `scaling_metric` - A type of target scaling. Needs to be either `cpu` or `memory`. Default is no scaling.
* `scaling_threshold` - The percentage in which the scaling metric will trigger a scaling event. Default is no scaling.
* `deployment_maximum_percent` - Upper limit on the number of running tasks that can be during a deployment. Default is 200.
* `deployment_minimum_healthy_percent` - Lower limit percentage of tasks that must be reporting healthy during a deployment. Default is 100.
* `efs_configs` - List of {file_system_id, root_directory, container_path, container_name} EFS mounts.
* `log_group_name` - The name of the log group. By default the `family` variable will be used.
* `log_group_retention_in_days` - The number of days to retain the log group. By default logs will never expire.
* `log_group_region` - The region where the log group exists. By default the current region will be used.
* `task_cpu` - How much CPU should be reserved for the container (in aws cpu-units). Default is `256`.
* `task_memory` - How much Memory should be reserved for the container (in MB). Default is `512`.
* `container_port` - Port the container listens on. Default is `80` (only valid with single container configurations, if using more then one container the port will need to be defined with your container definitions).
* `health_check_path` - A relative path for the services health checker to hit. Default is `/`.
* `health_check_healthy_threshold` - The number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 10.
* `health_check_unhealthy_threshold` - The number of consecutive health check failures required before considering the target unhealthy. Defaults to 10.
* `health_check_timeout` - The amount of time, in seconds, during which no response means a failed health check. Defaults to 2.
* `health_check_interval` - The approximate amount of time, in seconds, between health checks of an individual target. Defaults to 30.
* `health_check_matcher` - The HTTP codes to use when checking for a successful response from a target. Defaults to `200-399`.
* `platform_version` - The ECS backend platform version; Defaults to `1.4.0` so EFS is supported.
* `task_policy_json` - A JSON formatted IAM policy providing the running container with permissions.  By default, no permissions granted.

##### Network and Routing Configuration

* `vpc_id` - The VPC Id in which resources will be provisioned. Default is the default AWS vpc.
* `private_subnet_ids` - A set if subnet Id's. If configured will be associated with the Fargate service. If not configured and `public_subnet_ids` contains value they will be associated instead. If no public or private subnet Id's are passed to the module then the VPCs default subnets will be used and the ALB will be public-facing.
* `public_subnet_ids` - A set of subnet Id's. If configured will be associated with the ALB. If not configured and `private_subnet_ids` contains value the ALB will be internal-facing. If no public or private subnet Id's are passed to the module then the VPCs default subnets will be used and the ALB will be public-facing.
* `security_group_ids` - A set of additional security group ID's that will associated to the Fargate service network interface. Default is `[]`.
* `certificate_arn` - A certificate ARN being managed via ACM. If provided we will redirect 80 to 443 and serve on 443/https. Otherwise traffic will be served on 80/http.
* `hosted_zone_id` - The hosted zone ID where the A record will be created. Required if `certificate_arn` is set.
* `service_fqdn` - Fully qualified domain name (www.example.com) you wish to use for your service. Must be valid against the ACM cert provided. Required if `certificate_arn` is set.
* `route53_allow_overwrite` - Set the `allow_overwrite` property of the route53 record.  If `true`, there will be no `terraform import` necessary for pre-existing records. Default is `false`.
* `alb_log_bucket_name` - The S3 bucket name to store the ALB access logs in.
* `alb_log_prefix` - Prefix for each object created in ALB access log bucket.
* `use_cloudfront` - When `true` this module will attempt to provision a CF distribution. If a `certificate_arn` is used then both `hosted_zone_id` and `service_fqdn` will be required. Otherwise the default CF certificate is used. Default is `false`
* `cloudfront_blacklist_geo_restrictions` - A set of alpha-2 country codes. Request originating from these countries will be blocked and all other will be allowed. Must either use `cloudfront_blacklist_geo_restrictions` or `cloudfront_whitelist_geo_restrictions` but not both. By default a blacklist is used but no countries will be blocked.
* `cloudfront_whitelist_geo_restrictions` - A set of alpha-2 country codes. Request originating from these countries will be allowed and all other will be blocked. Must either use `cloudfront_blacklist_geo_restrictions` or `cloudfront_whitelist_geo_restrictions` but not both. By default a blacklist is used but no countries will be blocked.
* `cloudfront_origin_custom_headers` - A set of custom headers (name/value pairs) that will be passed to the origin. Typically used to pass a secret header and value to an ALB with a WAF to prevent connections directly to the ALB except when this secret header and value are present.
* `global_waf_acl_id` - An AWS Global Web Application Firewall ID that will be attached to the CF distribution. By default no association will be made.
* `regional_waf_acl_id` - An AWS Regional Web Application Firewall ID that will be attached to the ALB. By default no association will be made.
* `cloudfront_log_bucket_name` - The S3 bucket name to store the CF access logs in. By default no logs will be stored.
* `cloudfront_log_prefix` - Prefix for each object created in CF access log bucket. By default no prefix will be used.
* `deregistration_delay` - The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 20 seconds.
* `listeners` - The ALB listener port configuration. By default port 80 will be forwarded unless a certificate is provided then port 80 will redirect to port 443 which will then be forwarded. Here are some [examples](./examples/listener/main.tf) of listener configurations.

##### Tagging

All tags are optional maps of key-value pairs, and default to empty

* `tags` - Tags to apply to all resources
* `tags_ecs` - Tags to apply to all ecs resources
* `tags_ecs_task_definition` - Tags to apply to the task definition
* `tags_ecs_service` - Tags to apply to the ECS service
* `tags_security_group` - Tags to apply to the security groups
* `tags_alb` - Tags to apply to ALB resources
* `tags_alb_tg` - Tags to apply to the ALB target group
* `tags_cloudfront` - Tags to apply to CloudFront
* `tags_iam_role` - Tags to apply to the IAM Roles

* `tags_ecs_service_enabled` - Enable/Disable all tags on ECS Service to avoid conflicts with Accounts/Clusters using the old ARN formats.  Defaults to true, adding tags to all ecs services

## Examples

### Working examples

See the [examples directory](./examples) for some working terraform examples using different features

### Simple Example

With this module you can deploy an http Fargate service with *just* two(2) variables. Yeah you heard that right, TWO VARIABLES. But be warned, this is as basic as it gets. Be warned that the container is publicly accessible to the internet, so **use this method with caution!** We can't advise it but we can't help but emphasize the **easy** in `easy-fargate-service`.

The following example deploys a single container Fargate service on port 80 on the AWS default vpc:

```terraform
module "my-ez-fargate-service" {
  source             = "USSBA/easy-fargate-service/aws"
  version            = "~> 4.0"
  family             = "my-ez-fargate-service"
  container_image    = "nginx:latest"
}
```

### Realistic Example

An example with multiple containers, scaling configured, environment variables, and secrets sitting behind a CloudFront distribution:

```terraform
module "my-ez-fargate-service" {
  source             = "USSBA/easy-fargate-service/aws"
  version            = "~> 4.0"
  family             = "my-ez-fargate-service"
  container_image    = "nginx:latest"
  cluster_name       = "my-ecs-cluster"
  desired_capacity   = 2
  max_capacity       = 4
  min_capacity       = 2
  scaling_metric     = "cpu"
  scaling_threshold  = 75
  vpc_id             = "vpc-1234abcd"
  private_subnet_ids = ["subnet-11111111", "subnet-22222222", "subnet-33333333"]
  public_subnet_ids  = ["subnet-44444444", "subnet-55555555", "subnet-66666666"]
  certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-90ab-cdef-1234-567890abcdef"
  hosted_zone_id     = "Z000000000000"
  service_fqdn       = "www.cheeseburger.com"
  use_cloudfront     = true
  container_environment = [
    {
      name  = "FOO"
      value = "bar"
    }
  ]
  container_secrets = [
    {
      name      = "FOO_SECRET"
      valueFrom = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/foo_secret"
    }
  ]
}
```

## Contributing

We welcome contributions.
To contribute please read our [CONTRIBUTING](CONTRIBUTING.md) document.

All contributions are subject to the license and in no way imply compensation for contributions.

### Terraform 0.12

Our code base now exists in Terraform 0.13 and we are halting new features in the Terraform 0.12 major version.  If you wish to make a PR or merge upstream changes back into 0.12, please submit a PR to the `terraform-0.12` branch.

## Code of Conduct

We strive for a welcoming and inclusive environment for all SBA projects.

Please follow this guidelines in all interactions:

* Be Respectful: use welcoming and inclusive language.
* Assume best intentions: seek to understand other's opinions.

## Security Policy

Please do not submit an issue on GitHub for a security vulnerability.
Instead, contact the development team through [HQVulnerabilityManagement](mailto:HQVulnerabilityManagement@sba.gov).
Be sure to include **all** pertinent information.
