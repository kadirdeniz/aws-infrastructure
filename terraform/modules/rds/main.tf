resource "aws_db_instance" "this" {
  identifier              = var.identifier
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  port                    = var.port
  vpc_security_group_ids  = var.vpc_security_group_ids
  db_subnet_group_name    = var.db_subnet_group_name
  multi_az                = var.multi_az
  publicly_accessible     = false
  storage_encrypted       = true
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = true
  tags = merge({
    Name        = var.identifier
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "terraform"
  }, var.tags)
} 