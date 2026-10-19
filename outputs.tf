output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private application subnets."
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of isolated database subnets."
  value       = module.vpc.database_subnet_ids
}

output "all_subnet_ids" {
  description = "IDs of all subnets, grouped by tier."
  value       = module.vpc.all_subnet_ids
}

output "alb_security_group_id" {
  description = "ID of the ALB security group."
  value       = module.security_groups.alb_security_group_id
}

output "app_security_group_id" {
  description = "ID of the application security group."
  value       = module.security_groups.app_security_group_id
}

output "database_security_group_id" {
  description = "ID of the database security group."
  value       = module.security_groups.database_security_group_id
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group."
  value       = module.security_groups.bastion_security_group_id
}
