module "ecs" {
  source                                 = "terraform-aws-modules/ecs/aws"
  version                                = "~> 5.7.0"
  cluster_name                           = local.ecs_cluster_name
  cloudwatch_log_group_retention_in_days = 7
  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/${local.ecs_cluster_name}"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = var.tags
}
