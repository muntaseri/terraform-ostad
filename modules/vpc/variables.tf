variable "project_name" {
  description = "Project name used in resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment used in resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC; must fit six /20 or smaller subnet ranges."
  type        = string
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for both AZs when true, or one per AZ when false."
  type        = bool
}
