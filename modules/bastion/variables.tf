variable "project_name" {
  description = "Project name used in resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment used in resource names."
  type        = string
}

variable "owner" {
  description = "Owner tag value."
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID in which to launch the bastion."
  type        = string
}

variable "bastion_security_group_id" {
  description = "Security group ID assigned to the bastion."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the bastion."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Optional EC2 key pair name; Session Manager does not require an SSH key."
  type        = string
  default     = null
  nullable    = true
}
