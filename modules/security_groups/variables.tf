variable "project_name" {
  description = "Project name used in security group names."
  type        = string
}

variable "environment" {
  description = "Deployment environment used in security group names."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC in which to create the security groups."
  type        = string
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
