variable "project_name" {
  description = "Project name used in the database identifier."
  type        = string
}

variable "environment" {
  description = "Deployment environment used in the database identifier."
  type        = string
}

variable "database_subnet_ids" {
  description = "Private database subnet IDs spanning at least two availability zones."
  type        = list(string)

  validation {
    condition     = length(var.database_subnet_ids) >= 2
    error_message = "At least two database subnet IDs are required."
  }
}

variable "database_security_group_id" {
  description = "Security group ID allowing MySQL from the application tier."
  type        = string
}

variable "database_name" {
  description = "Initial MySQL database name."
  type        = string
  default     = "appdb"
}

variable "master_username" {
  description = "RDS master username; the password is generated and managed by RDS."
  type        = string
  default     = "dbadmin"
}

variable "engine_version" {
  description = "MySQL engine version."
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "allocated_storage" {
  description = "Initial allocated storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum autoscaled storage in GiB."
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Whether to deploy a synchronous standby in another AZ."
  type        = bool
}

variable "deletion_protection" {
  description = "Whether to prevent accidental deletion of the database."
  type        = bool
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups (0-35)."
  type        = number

  validation {
    condition = (
      var.backup_retention_period >= 0 &&
      var.backup_retention_period <= 35 &&
      var.backup_retention_period == floor(var.backup_retention_period)
    )
    error_message = "backup_retention_period must be a whole number of days between 0 and 35."
  }
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when the database is deleted."
  type        = bool
}
