variable "project_name" {
  description = "Name of the project, used for resource tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "The environment must be either \"dev\" or \"prod\"."
  }
}

variable "aws_region" {
  description = "AWS region in which to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The vpc_cidr value must be a valid IPv4 CIDR block."
  }
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway in dev by default; set false for one NAT gateway per AZ."
  type        = bool
  default     = null
  nullable    = true
}

variable "owner" {
  description = "Owner value applied to the default resource tags."
  type        = string
  default     = "terraform"
}

variable "allowed_ssh_cidr" {
  description = "Optional administrator IPv4 /32 allowed to SSH to the bastion; null disables SSH ingress."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = var.allowed_ssh_cidr == null || (
      can(cidrhost(var.allowed_ssh_cidr, 0)) &&
      can(regex("/32$", var.allowed_ssh_cidr))
    )
    error_message = "allowed_ssh_cidr must be null or a valid IPv4 /32 CIDR."
  }
}

variable "app_instance_type" {
  description = "EC2 instance type for the application Auto Scaling group."
  type        = string
  default     = "t3.micro"
}

variable "app_min_size" {
  description = "Minimum application Auto Scaling group capacity."
  type        = number
  default     = 2

  validation {
    condition     = var.app_min_size >= 1 && var.app_min_size == floor(var.app_min_size)
    error_message = "app_min_size must be a positive whole number."
  }
}

variable "app_desired_capacity" {
  description = "Desired application Auto Scaling group capacity."
  type        = number
  default     = 2

  validation {
    condition = (
      var.app_desired_capacity == floor(var.app_desired_capacity) &&
      var.app_desired_capacity >= var.app_min_size
    )
    error_message = "app_desired_capacity must be a whole number greater than or equal to app_min_size."
  }
}

variable "app_max_size" {
  description = "Maximum application Auto Scaling group capacity."
  type        = number
  default     = 4

  validation {
    condition = (
      var.app_max_size == floor(var.app_max_size) &&
      var.app_max_size >= var.app_desired_capacity &&
      var.app_desired_capacity >= var.app_min_size
    )
    error_message = "Capacity values must be whole numbers and satisfy app_min_size <= app_desired_capacity <= app_max_size."
  }
}

variable "db_name" {
  description = "Initial database name for the MySQL instance."
  type        = string
  default     = "appdb"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_multi_az" {
  description = "Override Multi-AZ; defaults off for dev and on for prod."
  type        = bool
  default     = null
  nullable    = true
}

variable "db_deletion_protection" {
  description = "Override deletion protection; defaults off for dev and on for prod."
  type        = bool
  default     = null
  nullable    = true
}

variable "db_backup_retention_period" {
  description = "Override automated backup retention in days; defaults to 1 for dev and 7 for prod."
  type        = number
  default     = null
  nullable    = true

  validation {
    condition = var.db_backup_retention_period == null ? true : (
      var.db_backup_retention_period >= 0 &&
      var.db_backup_retention_period <= 35 &&
      var.db_backup_retention_period == floor(var.db_backup_retention_period)
    )
    error_message = "db_backup_retention_period must be null or a whole number of days between 0 and 35."
  }
}

variable "db_skip_final_snapshot" {
  description = "Override final snapshot behavior; defaults to skip for dev and retain for prod."
  type        = bool
  default     = null
  nullable    = true
}

variable "enable_bastion" {
  description = "Whether to create the optional public bastion host."
  type        = bool
  default     = false
}

variable "bastion_instance_type" {
  description = "EC2 instance type for the optional bastion."
  type        = string
  default     = "t3.micro"
}

variable "bastion_key_name" {
  description = "Optional SSH key pair for the bastion; prefer Session Manager."
  type        = string
  default     = null
  nullable    = true
}
