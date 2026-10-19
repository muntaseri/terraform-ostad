variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment shown on the web page and in resource names."
  type        = string
}

variable "owner" {
  description = "Owner value for launched instance and volume tags."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs across the selected availability zones."
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group ID assigned to application instances."
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN attached to the Auto Scaling group."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for application instances."
  type        = string
}

variable "min_size" {
  description = "Minimum number of application instances."
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of application instances."
  type        = number
}

variable "max_size" {
  description = "Maximum number of application instances."
  type        = number
}
