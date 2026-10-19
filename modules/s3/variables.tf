variable "project_name" {
  description = "Project name used in the bucket name."
  type        = string

  validation {
    condition     = can(regex("[A-Za-z0-9]", var.project_name))
    error_message = "project_name must contain at least one letter or digit for a valid bucket name."
  }
}

variable "environment" {
  description = "Deployment environment used in the bucket name."
  type        = string
}
