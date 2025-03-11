# ECS Falco Example

<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | ~> 2.3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.16.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.33.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.12.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0.0 |

## Usage

The basic usage of this module is as follows:

```hcl
  module "example" {
    	 source  = "<module-path>"

	 # Optional variables
    	 aws_region  = "us-east-1"
    	 cloudtrail_is_multi_region_trail  = true
    	 cloudtrail_kms_enable  = true
    	 cloudtrail_sns_arn  = "create"
    	 name  = "falco-ecs"
    	 tags  = {
  "product": "falcosecurity-for-cloud"
}
  }
  ```

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy resources | `string` | `"us-east-1"` | no |
| <a name="input_cloudtrail_is_multi_region_trail"></a> [cloudtrail\_is\_multi\_region\_trail](#input\_cloudtrail\_is\_multi\_region\_trail) | true/false whether cloudtrail will ingest multiregional events | `bool` | `true` | no |
| <a name="input_cloudtrail_kms_enable"></a> [cloudtrail\_kms\_enable](#input\_cloudtrail\_kms\_enable) | true/false whether cloudtrail delivered events to S3 should persist encrypted | `bool` | `true` | no |
| <a name="input_cloudtrail_sns_arn"></a> [cloudtrail\_sns\_arn](#input\_cloudtrail\_sns\_arn) | ARN of a pre-existing cloudtrail\_sns. If defaulted, a new cloudtrail will be created | `string` | `"create"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"falco-ecs"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | falcosecurity-for-cloud tags. always include 'product' default tag for resource-group proper functioning | `map(string)` | <pre>{<br/>  "product": "falcosecurity-for-cloud"<br/>}</pre> | no |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudtrail"></a> [cloudtrail](#module\_cloudtrail) | ../../modules/infrastructure/cloudtrail | n/a |
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | ../../modules/infrastructure/ecs | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | ../../modules/infrastructure/resource-group | n/a |
| <a name="module_sqs_sns_subscription"></a> [sqs\_sns\_subscription](#module\_sqs\_sns\_subscription) | ../../modules/infrastructure/sqs-sns-subscription | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/infrastructure/vpc | n/a |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudtrail_sns_subscribed_sqs_arn"></a> [cloudtrail\_sns\_subscribed\_sqs\_arn](#output\_cloudtrail\_sns\_subscribed\_sqs\_arn) | ARN of the cloudtrail-sns subscribed sqs |
| <a name="output_cloudtrail_sns_subscribed_sqs_url"></a> [cloudtrail\_sns\_subscribed\_sqs\_url](#output\_cloudtrail\_sns\_subscribed\_sqs\_url) | URL of the cloudtrail-sns subscribed sqs |
| <a name="output_get_falcosidekick_local"></a> [get\_falcosidekick\_local](#output\_get\_falcosidekick\_local) | Command to get the falcosidekick UI via port-forward |
<!-- END_TF_DOCS -->
