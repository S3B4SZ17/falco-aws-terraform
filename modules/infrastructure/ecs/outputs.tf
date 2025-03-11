output "target_groups" {
  value       = length(module.alb) > 0 ? module.alb[0].target_groups : null
  description = "Map of target groups created and their attributes"
}

output "security_group_id" {
  value       = length(module.alb) > 0 ? module.alb[0].security_group_id : null
  description = "ID of the security group"
}

output "ecs_cluster_id" {
  value       = module.ecs.cluster_id
  description = "The ECS cluster ID"
}

output "ecs_cluster_arn" {
  value       = module.ecs.cluster_arn
  description = "The ECS cluster ARN"
}
