module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.identifier}-db"

  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  family               = "${var.db_engine}${var.db_engine_version}"
  major_engine_version = var.db_major_engine_version

  db_name                     = var.db_name
  username                    = var.db_username
  port                        = var.db_port
  manage_master_user_password = true
  multi_az                    = var.db_multi_az
  db_subnet_group_name        = var.db_subnet_group_name
  vpc_security_group_ids      = var.db_security_group_ids
  allocated_storage           = var.db_allocated_storage
  max_allocated_storage       = var.db_max_allocated_storage

  maintenance_window = var.db_maintenance_window

  backup_window           = var.db_backup_window
  backup_retention_period = var.db_backup_retaintion_period
  skip_final_snapshot     = var.db_skip_final_snapshot
  deletion_protection     = var.db_deletion_protection

  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  create_cloudwatch_log_group           = true
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  parameters                            = var.db_parameters
}
