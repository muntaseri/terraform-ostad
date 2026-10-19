output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets, one per availability zone."
  value       = [for zone in local.availability_zones : aws_subnet.public[zone].id]
}

output "private_subnet_ids" {
  description = "IDs of the private application subnets, one per availability zone."
  value       = [for zone in local.availability_zones : aws_subnet.private[zone].id]
}

output "database_subnet_ids" {
  description = "IDs of the isolated database subnets, one per availability zone."
  value       = [for zone in local.availability_zones : aws_subnet.database[zone].id]
}

output "all_subnet_ids" {
  description = "IDs of all VPC subnets, grouped by public, private, then database tier."
  value = concat(
    [for zone in local.availability_zones : aws_subnet.public[zone].id],
    [for zone in local.availability_zones : aws_subnet.private[zone].id],
    [for zone in local.availability_zones : aws_subnet.database[zone].id],
  )
}
