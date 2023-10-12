module "db" {
  source     = "terraform-aws-modules/rds/aws"
  identifier = var.postgres.instance_name

  engine         = "postgres"
  family         = var.postgres.family
  engine_version = var.postgres.instance_version
  instance_class = var.postgres.instance_class

  allocated_storage       = var.postgres.allocated_storage
  max_allocated_storage   = var.postgres.max_allocated_storage
  backup_retention_period = var.postgres.backup_retention
  maintenance_window      = var.postgres.maintenance_window
  backup_window           = var.postgres.backup_window

  db_name  = var.postgres.database_name
  username = var.postgres.database_user_name
  port     = 5432

  db_subnet_group_name = var.db_subnet_group
  vpc_security_group_ids = [
    var.security_group_rds_id
  ]
}