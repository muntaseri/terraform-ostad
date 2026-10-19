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
