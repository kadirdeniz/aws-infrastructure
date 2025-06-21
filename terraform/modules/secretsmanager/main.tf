resource "random_password" "db_password" {
  length  = 16
  special = true
  numeric = true
  upper   = true
  lower   = true
}

resource "aws_secretsmanager_secret" "app_credentials" {
  name                    = var.secret_name
  description             = var.secret_description
  recovery_window_in_days = var.recovery_window_in_days
  
  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  })
}

# Create the secret value with all credentials and configuration
locals {
  secret_data = merge({
    # Database credentials
    db_host     = var.db_host
    db_port     = var.db_port
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    
    # S3 bucket information
    s3_backend_bucket_name  = var.s3_backend_bucket_name
    s3_frontend_bucket_name = var.s3_frontend_bucket_name
    s3_backend_bucket_arn   = var.s3_backend_bucket_arn
    s3_frontend_bucket_arn  = var.s3_frontend_bucket_arn
    
    # Environment information
    environment = var.environment
    project     = var.project
    region      = data.aws_region.current.name
  }, var.api_keys)
}

resource "aws_secretsmanager_secret_version" "app_credentials" {
  secret_id     = aws_secretsmanager_secret.app_credentials.id
  secret_string = jsonencode(local.secret_data)
}

# Enable rotation if requested
resource "aws_secretsmanager_secret_rotation" "app_credentials" {
  count               = var.enable_rotation ? 1 : 0
  secret_id           = aws_secretsmanager_secret.app_credentials.id
  rotation_rules {
    automatically_after_days = 30
  }
}

# Data source for current region
data "aws_region" "current" {} 