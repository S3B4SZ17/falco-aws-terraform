# ECS Cluster

## Description

This module contains the configuration for creating a new ECS cluster. The outputs can be used in other modules to configure the necessary task definitions.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.29.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.23 |

## Usage

The basic usage of this module is as follows:

```hcl
  module "example" {
    	 source  = "<module-path>"

	 # Required variables
    	 cidr  =
    	 ecs_cluster_name  =
    	 private_subnets  =

	 # Optional variables
    	 alb_name  = "faragate"
    	 container_port  = 3000
    	 deploy_alb  = false
    	 deploy_web_app  = false
    	 public_subnets  = []
    	 tags  = {
  "Environment": "Staging",
  "ManagedBy": "Terraform",
  "Project": "ecs-cluster"
}
    	 vpc_id  = ""
  }
  ```

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.aws_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.instrumented_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.aws_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.aws_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.aws_events_exec_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.aws_events_exec_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_security_group.aws_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_service_discovery_http_namespace.aws_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_http_namespace) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.aws_events_exec_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.aws_events_exec_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | The ALB name | `string` | `"faragate"` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | CIDR Block definition | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The s3automation container port | `number` | `3000` | no |
| <a name="input_deploy_alb"></a> [deploy\_alb](#input\_deploy\_alb) | Wether to deploy the ALB or not | `bool` | `false` | no |
| <a name="input_deploy_web_app"></a> [deploy\_web\_app](#input\_deploy\_web\_app) | Specify whether we should deploy the web app for falcosidekick | `bool` | `false` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | The ECS cluster name | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnets | `list(string)` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List of public subnets | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags for the resources | `map(any)` | <pre>{<br/>  "Environment": "Staging",<br/>  "ManagedBy": "Terraform",<br/>  "Project": "ecs-cluster"<br/>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID | `string` | `""` | no |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | ~> 9.2.0 |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | terraform-aws-modules/ecs/aws | ~> 5.7.0 |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | The ECS cluster ARN |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | The ECS cluster ID |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
| <a name="output_target_groups"></a> [target\_groups](#output\_target\_groups) | Map of target groups created and their attributes |
<!-- END_TF_DOCS -->
