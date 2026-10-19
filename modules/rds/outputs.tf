output "endpoint" {
  description = "RDS endpoint hostname and port."
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "RDS endpoint hostname."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS MySQL port."
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Initial database name."
  value       = aws_db_instance.this.db_name
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret generated and managed by RDS."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
