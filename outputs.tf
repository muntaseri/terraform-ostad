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

output "alb_dns_name" {
  description = "Public DNS name of the application load balancer."
  value       = module.alb.alb_dns_name
}

output "app_autoscaling_group_name" {
  description = "Name of the application Auto Scaling group."
  value       = module.app.autoscaling_group_name
}

output "db_endpoint" {
  description = "RDS database endpoint hostname and port."
  value       = module.rds.endpoint
}

output "db_name" {
  description = "Name of the initial MySQL database."
  value       = module.rds.database_name
}

output "db_master_user_secret_arn" {
  description = "ARN of the RDS-managed master credential secret; the password is never output."
  value       = module.rds.master_user_secret_arn
}

output "s3_bucket_name" {
  description = "Name of the private, versioned application S3 bucket."
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the private application S3 bucket."
  value       = module.s3.bucket_arn
}

output "bastion_instance_id" {
  description = "Bastion instance ID when the optional bastion is enabled."
  value       = var.enable_bastion ? module.bastion[0].instance_id : null
}

output "bastion_public_ip" {
  description = "Bastion public IP when the optional bastion is enabled."
  value       = var.enable_bastion ? module.bastion[0].public_ip : null
}
