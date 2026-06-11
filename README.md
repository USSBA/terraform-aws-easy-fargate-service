**This repository has been archived and is no longer maintained.**

# terraform-aws-easy-fargate-service

This module simplifies deploying containerized applications using AWS Fargate and ECS.

## Features

- AWS Fargate ECS service with task definition
- Provides support for internal and public-facing Application Load Balancers (ALBs).
- Health checks and sticky sessions
- Auto scaling and scheduled scaling
- CloudWatch logging with configurable retention
- Optional regional WAF, Shield, and DNS integration
- Tagging support across all resources

## Prerequisites

To use this module, ensure you have the following:

- **Terraform**: `~> 1.9`
- **AWS Provider**: `~> 5.0`
- **AWS Account**: Configured with appropriate permissions to create ECS, ALB, IAM, and related resources
- **VPC and Subnets**: A pre-existing VPC with private subnets (and optionally public subnets for public-facing ALBs)
- **Security Groups**: Two pre-existing AWS security groups—one for the ECS tasks (`security_group_ids`) and one for the ALB (`alb_security_group_ids`)
- **Optional Resources** (if used):
  - ECS Cluster (If `cluster_name` is not specified, the module uses the AWS-managed default cluster named `"default"`. If this cluster is missing (e.g., deleted or not created), create it with `aws ecs create-cluster --cluster-name default` or specify an existing cluster via `cluster_name`.)
  - ACM certificates (if `certificate_arns` is provided for HTTPS)
  - Route53 hosted zone (if `hosted_zone_id` is provided for DNS)
  - EFS file system (if `efs_configs` is used)
  - S3 bucket (if `alb_log_bucket_name` is used for ALB logs)
  - Regional WAF ACL (if `regional_waf_acl` is used)

## Core Inputs

| Name                     | Description                                                                 | Type            | Required |
|--------------------------|-----------------------------------------------------------------------------|------------------|----------|
| `family`                | A unique name for the service family. Used for naming ECS and other resources. | `string`         | ✅ Yes    |
| `container_definitions` | JSON-encoded list of container definitions. Must include `name` and `image`. | `string`         | ✅ Yes    |
| `vpc_id`                | VPC ID for ECS service networking.                                           | `string`         | ✅ Yes    |
| `private_subnet_ids`    | List of subnet IDs for the service (ALB will be internal unless public subnets are given). | `list(string)`   | ✅ Yes    |
| `security_group_ids`    | Security group IDs for the ECS tasks.                                       | `list(string)`   | ✅ Yes    |
| `alb_security_group_ids`| Security group IDs for the Application Load Balancer.                       | `list(string)`   | ✅ Yes    |
| `desired_capacity`      | Desired number of ECS tasks. Default: `1`.                                    | `number`         | ❌ No     |
| `task_cpu`              | Fargate-compliant CPU units. Default: `256`.                                  | `number`         | ❌ No     |
| `task_memory`           | Fargate-compliant memory value. Default: `512`.                               | `number`         | ❌ No     |
| `tags`                  | Key-value map of tags applied to all resources. Default: `{}`.                | `map(any)`       | ❌ No     |

## Optional/Advanced Inputs

### Load Balancer

| Name                             | Description                                               | Default         |
|----------------------------------|-----------------------------------------------------------|-----------------|
| `alb_idle_timeout`               | ALB idle timeout in seconds.                              | `60`            |
| `alb_sticky_duration`            | Enables sticky sessions (in seconds).                     | `1`             |
| `alb_sticky_cookie_type`         | Sticky session cookie type (`lb_cookie` or `app_cookie`). | `lb_cookie`     |  
| `alb_drop_invalid_header_fields` | Drop invalid HTTP headers.                                | `false`         |
| `public_subnet_ids`              | Subnet IDs to make ALB public-facing.                     | `[]`            |

### Logging

| Name                            | Description                                   | Default            |
|---------------------------------|-----------------------------------------------|--------------------|
| `log_group_name`                | Log group name (defaults to `family` name).     | `""`               |
| `log_group_retention_in_days`   | CloudWatch log retention in days.             | `0`                |
| `task_log_configuration_options`| Override log config options.                  | `{}`               |

### Scaling

| Name                        | Description                                   | Default            |
|-----------------------------|-----------------------------------------------|--------------------|
| `min_capacity`              | Minimum ECS service capacity.                 | `-1`               |
| `max_capacity`              | Maximum ECS service capacity.                 | `-1`               |
| `scaling_metric`            | Auto scaling metric (`cpu` or `memory`).      | `""`               |
| `scaling_threshold`         | Threshold % to trigger scaling.               | `-1`               |
| `scheduled_actions`         | List of scheduled scaling actions.            | `[]`               |
| `scheduled_actions_timezone`| Timezone for scheduled scaling.               | `"UTC"`            |

### WAF & Shield

| Name                       | Description                                 | Default |
|----------------------------|---------------------------------------------|---------|
| `enable_shield_protection` | Enables AWS Shield protection for ALB.      | `false` |
| `regional_waf_acl`         | ARN of an existing regional WAFv2 Web ACL to associate with the Application Load Balancer (ALB). | `""`    |

**NOTE:** Setting `enable_shield_protection = true` will attempt to enable [AWS Shield Advanced](https://aws.amazon.com/shield/) protection on the Application Load Balancer (ALB) created by this module.

This does not automatically enroll your AWS account in Shield Advanced. Your account **must already be enrolled** in Shield Advanced for this setting to take effect.

**IMPORTANT:** AWS Shield Advanced incurs a **$3,000/month/account** charge, regardless of how many resources are protected. Be sure you understand the pricing and have completed the necessary enrollment steps before enabling this option.

### DNS/HTTPS

| Name                     |Description                                                                          | Default |
|--------------------------|-------------------------------------------------------------------------------------|---------|
| `hosted_zone_id`         | ID of an existing Route 53 hosted zone. Required to create a DNS record.            | `""`    |
| `service_fqdn`           | Domain name for the service; used with `hosted_zone_id` to create a Route 53 record.| `""`    |
| `certificate_arns`       | One or more ACM certificate ARNs to enable HTTPS on the ALB.                        | `[]`    |
| `route53_allow_overwrite`| Allow overwrite of existing Route53 records.                                        | `false` |

## Outputs

| Name                    | Description                                            |
|-------------------------|--------------------------------------------------------|
| `task_definition`       | The ECS task definition object.                        |
| `service`               | The ECS service object.                                |
| `task_role`             | The IAM role used by the ECS tasks.                    |
| `alb_dns`               | The DNS name of the Application Load Balancer.         |
| `alb`                   | The Application Load Balancer object.                  |

## Notes

- For a full list of inputs, see [module inputs](https://registry.terraform.io/modules/USSBA/easy-fargate-service/aws/latest?tab=inputs).
- This module assumes IAM permissions and VPC networking is already set up.
- This module supports both public and internal ALBs. User must provide `public_subnet_ids` in order for ALB to be public facing.
- This module does not create a CloudFront distribution but supports integration with an existing one by using `cloudfront_header` to secure ALB access with a custom header, blocking unauthorized requests without the header. Configure the header in your CloudFront distribution’s origin settings and use the `alb_dns` output as the origin.

## Usage

### Working examples

See the [examples directory](./examples) for some working terraform examples using different features.

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
  certificate_arns   = ["arn:aws:acm:us-east-1:123456789012:certificate/12345678-90ab-cdef-1234-567890abcdef"]
  hosted_zone_id     = "Z000000000000"
  service_fqdn       = "www.cheeseburger.com"
  cloudfront_header = {
    key   = "x-header-name"
    value = "12345678-90ab-cdef-1234-567890abcdef"
  }
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

We welcome contributions. To contribute please read our [CONTRIBUTING](CONTRIBUTING.md) document.

All contributions are subject to the license and in no way imply compensation for contributions.

## Code of Conduct

We strive for a welcoming and inclusive environment for all SBA projects.

Please follow this guidelines in all interactions:

- Be Respectful: use welcoming and inclusive language.
- Assume best intentions: seek to understand other's opinions.

## Security Policy

Please do not submit an issue on GitHub for a security vulnerability.
Instead, contact the development team through [HQVulnerabilityManagement](mailto:HQVulnerabilityManagement@sba.gov).
Be sure to include **all** pertinent information.
