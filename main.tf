locals {
  effective_single_nat_gateway = var.single_nat_gateway == null ? var.environment == "dev" : var.single_nat_gateway
  effective_db_multi_az        = var.db_multi_az == null ? var.environment == "prod" : var.db_multi_az
  effective_db_deletion_protection = (
    var.db_deletion_protection == null ? var.environment == "prod" : var.db_deletion_protection
  )
  effective_db_backup_retention_period = (
    var.db_backup_retention_period == null ? (var.environment == "prod" ? 7 : 1) : var.db_backup_retention_period
  )
  effective_db_skip_final_snapshot = (
    var.db_skip_final_snapshot == null ? var.environment != "prod" : var.db_skip_final_snapshot
  )
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

  project_name               = var.project_name
  environment                = var.environment
  owner                      = var.owner
  private_subnet_ids         = module.vpc.private_subnet_ids
  app_security_group_id      = module.security_groups.app_security_group_id
  target_group_arn           = module.alb.target_group_arn
  rds_master_user_secret_arn = module.rds.master_user_secret_arn
  instance_type              = var.app_instance_type
  min_size                   = var.app_min_size
  desired_capacity           = var.app_desired_capacity
  max_size                   = var.app_max_size
}

module "rds" {
  source = "./modules/rds"

  project_name               = var.project_name
  environment                = var.environment
  database_subnet_ids        = module.vpc.database_subnet_ids
  database_security_group_id = module.security_groups.database_security_group_id
  database_name              = var.db_name
  instance_class             = var.db_instance_class
  multi_az                   = local.effective_db_multi_az
  deletion_protection        = local.effective_db_deletion_protection
  backup_retention_period    = local.effective_db_backup_retention_period
  skip_final_snapshot        = local.effective_db_skip_final_snapshot
}

module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
}

module "bastion" {
  count  = var.enable_bastion ? 1 : 0
  source = "./modules/bastion"

  project_name              = var.project_name
  environment               = var.environment
  owner                     = var.owner
  public_subnet_id          = module.vpc.public_subnet_ids[0]
  bastion_security_group_id = module.security_groups.bastion_security_group_id
  instance_type             = var.bastion_instance_type
  key_name                  = var.bastion_key_name
}
