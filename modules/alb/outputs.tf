output "alb_dns_name" {
  description = "Public DNS name of the application load balancer."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID of the application load balancer."
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN of the application target group."
  value       = aws_lb_target_group.app.arn
}
