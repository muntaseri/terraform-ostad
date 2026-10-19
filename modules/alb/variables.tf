variable "project_name" {
  description = "Project name used in resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment used in resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the ALB target group."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs in at least two availability zones."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID assigned to the ALB."
  type        = string
}
