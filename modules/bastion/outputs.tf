output "instance_id" {
  description = "ID of the bastion instance."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IPv4 address of the bastion instance."
  value       = aws_instance.this.public_ip
}
