locals {
  db_identifier = substr(
    trim(replace(lower("${var.project_name}-${var.environment}-mysql"), "/[^a-z0-9-]/", "-"), "-"),
    0,
    63,
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.db_identifier}-subnets"
  subnet_ids = var.database_subnet_ids

  tags = {
    Name = "${local.db_identifier}-subnets"
  }
}

resource "random_id" "final_snapshot" {
  byte_length = 4
}

resource "aws_db_instance" "this" {
  identifier                  = local.db_identifier
  engine                      = "mysql"
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  storage_type                = "gp3"
  storage_encrypted           = true
  db_name                     = var.database_name
  username                    = var.master_username
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.database_security_group_id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : (
    "${local.db_identifier}-final-${random_id.final_snapshot.hex}"
  )

  auto_minor_version_upgrade = true
  apply_immediately          = false
  copy_tags_to_snapshot      = true

  tags = {
    Name = local.db_identifier
  }
}
