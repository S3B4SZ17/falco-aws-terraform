output "vpc_id" {
  description = "The VPC ID where the EKS cluster will be created"
  value       = module.vpc.vpc_id
}

output "private_subnets_ids" {
  description = "List of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets_ids" {
  description = "List of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets_details" {
  description = "List of private subnets details"
  value       = data.aws_subnet.private
}

output "public_subnets_details" {
  description = "List of public subnets details"
  value       = data.aws_subnet.public
}

output "cidr_block" {
  description = "The CIDR block for the VPC"
  value       = module.vpc.vpc_cidr_block
}
