variable "tags" {
  type = map(any)
  default = {
    Project     = "ecs-cluster"
    ManagedBy   = "Terraform"
    Environment = "Staging"
  }
  description = "Map of tags for the resources"
}

variable "ecs_cluster_name" {
  type        = string
  description = "The ECS cluster name"
}

variable "alb_name" {
  type        = string
  default     = "faragate"
  description = "The ALB name"
}

variable "deploy_alb" {
  type        = bool
  default     = false
  description = "Wether to deploy the ALB or not"
}

variable "container_port" {
  type        = number
  default     = 3000
  description = "The s3automation container port"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnets"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnets"
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
  default     = ""
}

variable "cidr" {
  description = "CIDR Block definition"
  type        = string
}

variable "deploy_web_app" {
  type        = bool
  description = "Specify whether we should deploy the web app for falcosidekick"
  default     = false
}
