locals {
  ecs_cluster_name = var.ecs_cluster_name
  container_port   = var.container_port

  tags = merge(var.tags, {
    Project = "falco-ecs"
  })
}
