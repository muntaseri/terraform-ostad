output "autoscaling_group_name" {
  description = "Name of the application Auto Scaling group."
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "ID of the application launch template."
  value       = aws_launch_template.app.id
}
