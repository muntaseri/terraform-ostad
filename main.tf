locals {
  effective_single_nat_gateway = var.single_nat_gateway == null ? var.environment == "dev" : var.single_nat_gateway
}

module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  single_nat_gateway = local.effective_single_nat_gateway
}

module "security_groups" {
  source = "./modules/security_groups"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

module "alb" {
  source = "./modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
}

module "app" {
  source = "./modules/app"

  project_name          = var.project_name
  environment           = var.environment
  owner                 = var.owner
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_security_group_id = module.security_groups.app_security_group_id
  target_group_arn      = module.alb.target_group_arn
  instance_type         = var.app_instance_type
  min_size              = var.app_min_size
  desired_capacity      = var.app_desired_capacity
  max_size              = var.app_max_size
}
