terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  project              = var.project
  owner                = var.owner
  azs                  = var.azs
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

# IAM Module
module "iam" {
  source = "./modules/iam"
  
  environment = var.environment
  project     = var.project
  owner       = var.owner
  
  # Enable all roles
  enable_ecs_task_execution_role = true
  enable_ecs_task_role           = true
  enable_rds_access_role         = true
  enable_api_gateway_execution_role = true
  
  # Real Secrets Manager ARNs (will be updated after secrets_manager module)
  secrets_manager_arns = []
  
  # Real S3 bucket ARNs (will be updated after s3 module)
  s3_bucket_arns = []
  
  # Real RDS cluster ARN (will be updated after rds module)
  rds_cluster_arn = ""
  
  # Real ECS cluster ARN (will be updated after ecs module)
  ecs_cluster_arn = ""
  
  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

# S3 Module
module "s3" {
  source = "./modules/s3"
  
  environment        = var.environment
  project           = var.project
  owner             = var.owner
  ecs_task_role_arn = module.iam.ecs_task_role_arn
  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  identifier              = "${var.project}-${var.environment}-db"
  engine_version          = "14.12"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  port                    = 5432
  vpc_security_group_ids  = [module.vpc.default_security_group_id]
  db_subnet_group_name    = module.vpc.db_subnet_group_name
  multi_az                = false
  backup_retention_period = 7
  environment             = var.environment
  project                 = var.project
  owner                   = var.owner
  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

# Secrets Manager Module
module "secrets_manager" {
  source = "./modules/secretsmanager"
  
  secret_name = "${var.project}-${var.environment}-credentials"
  environment = var.environment
  project     = var.project
  owner       = var.owner
  
  # Database credentials
  db_host     = module.rds.db_endpoint
  db_port     = 5432
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  
  # S3 bucket information
  s3_backend_bucket_name  = module.s3.backend_bucket_name
  s3_frontend_bucket_name = module.s3.frontend_bucket_name
  s3_backend_bucket_arn   = module.s3.backend_bucket_arn
  s3_frontend_bucket_arn  = module.s3.frontend_bucket_arn
  
  # Optional API keys (empty for now)
  api_keys = {}
  
  enable_rotation = var.enable_secrets_rotation
  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

# Update IAM module with real ARNs
module "iam_updated" {
  source = "./modules/iam"
  
  environment = var.environment
  project     = var.project
  owner       = var.owner
  
  # Enable all roles
  enable_ecs_task_execution_role = true
  enable_ecs_task_role           = true
  enable_rds_access_role         = true
  enable_api_gateway_execution_role = true
  
  # Real Secrets Manager ARNs
  secrets_manager_arns = [module.secrets_manager.secret_arn]
  
  # Real S3 bucket ARNs
  s3_bucket_arns = module.s3.bucket_arns
  
  # Real RDS cluster ARN
  rds_cluster_arn = module.rds.db_arn
  
  # Real ECS cluster ARN (will be updated after ecs module)
  ecs_cluster_arn = ""
  
  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
  
  depends_on = [module.secrets_manager, module.s3, module.rds]
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"
  
  repository_names = ["${var.project}-${var.environment}-backend", "${var.project}-${var.environment}-frontend"]
  environment      = var.environment
  project          = var.project
  owner            = var.owner
  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"
  
  cluster_name = "${var.project}-${var.environment}-cluster"
  environment  = var.environment
  project      = var.project
  owner        = var.owner
  
  # Backend service
  backend_service_name = "${var.project}-${var.environment}-backend"
  backend_image        = var.backend_image
  backend_port         = 8080
  backend_cpu          = 256
  backend_memory       = 512
  
  # Frontend service
  frontend_service_name = "${var.project}-${var.environment}-frontend"
  frontend_image        = var.frontend_image
  frontend_port         = 80
  frontend_cpu          = 256
  frontend_memory       = 512
  
  # Network configuration
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  
  # IAM roles
  task_execution_role_arn = module.iam_updated.ecs_task_execution_role_arn
  task_role_arn           = module.iam_updated.ecs_task_role_arn
  
  # Secrets
  secrets_arn = module.secrets_manager.secret_arn
  
  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

# Final IAM update with ECS cluster ARN
module "iam_final" {
  source = "./modules/iam"
  
  environment = var.environment
  project     = var.project
  owner       = var.owner
  
  # Enable all roles
  enable_ecs_task_execution_role = true
  enable_ecs_task_role           = true
  enable_rds_access_role         = true
  enable_api_gateway_execution_role = true
  
  # Real Secrets Manager ARNs
  secrets_manager_arns = [module.secrets_manager.secret_arn]
  
  # Real S3 bucket ARNs
  s3_bucket_arns = module.s3.bucket_arns
  
  # Real RDS cluster ARN
  rds_cluster_arn = module.rds.db_arn
  
  # Real ECS cluster ARN
  ecs_cluster_arn = module.ecs.cluster_arn
  
  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
  
  depends_on = [module.ecs]
}

# API Gateway Module
module "api_gateway" {
  source = "./modules/apigateway"
  
  api_name = "${var.project}-${var.environment}-api"
  environment = var.environment
  project     = var.project
  owner       = var.owner
  
  # Backend service integration
  backend_service_name = module.ecs.backend_service_name
  backend_service_arn  = module.ecs.backend_service_arn
  
  # Frontend service integration
  frontend_service_name = module.ecs.frontend_service_name
  frontend_service_arn  = module.ecs.frontend_service_arn
  
  # VPC configuration
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  
  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

# CloudWatch Module
module "cloudwatch" {
  source = "./modules/cloudwatch"
  
  log_group_name = "/aws/ecs/${var.project}-${var.environment}"
  dashboard_name = "${var.project}-${var.environment}-dashboard"
  environment    = var.environment
  project        = var.project
  owner          = var.owner
  
  # Services to monitor
  backend_service_name  = module.ecs.backend_service_name
  frontend_service_name = module.ecs.frontend_service_name
  
  # Enable alarms
  enable_alarms = var.enable_cloudwatch_alarms
  
  tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
} 