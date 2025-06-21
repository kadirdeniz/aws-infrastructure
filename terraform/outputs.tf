// Define output values for the root Terraform configuration here. 

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

# S3 Outputs
output "backend_bucket_name" {
  description = "Backend S3 bucket name"
  value       = module.s3.backend_bucket_name
}

output "backend_bucket_arn" {
  description = "Backend S3 bucket ARN"
  value       = module.s3.backend_bucket_arn
}

output "frontend_bucket_name" {
  description = "Frontend S3 bucket name"
  value       = module.s3.frontend_bucket_name
}

output "frontend_bucket_arn" {
  description = "Frontend S3 bucket ARN"
  value       = module.s3.frontend_bucket_arn
}

output "s3_bucket_names" {
  description = "List of all S3 bucket names"
  value       = module.s3.bucket_names
}

output "s3_bucket_arns" {
  description = "List of all S3 bucket ARNs"
  value       = module.s3.bucket_arns
}

# RDS Outputs
output "db_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_endpoint
}

output "db_arn" {
  description = "RDS database ARN"
  value       = module.rds.db_arn
}

# ECR Outputs
output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = module.ecr.repository_urls
}

# ECS Outputs
output "cluster_arn" {
  description = "ECS cluster ARN"
  value       = module.ecs.cluster_arn
}

output "backend_service_name" {
  description = "Backend service name"
  value       = module.ecs.backend_service_name
}

output "frontend_service_name" {
  description = "Frontend service name"
  value       = module.ecs.frontend_service_name
}

# API Gateway Outputs
output "api_gateway_url" {
  description = "API Gateway URL"
  value       = module.api_gateway.api_url
}

output "api_gateway_arn" {
  description = "API Gateway ARN"
  value       = module.api_gateway.api_arn
}

# Secrets Manager Outputs
output "secrets_arn" {
  description = "Secrets Manager ARN"
  value       = module.secrets_manager.secret_arn
}

# CloudWatch Outputs
output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = module.cloudwatch.dashboard_url
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = module.cloudwatch.log_group_name
}

# IAM Outputs
output "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN"
  value       = module.iam_final.ecs_task_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ECS task role ARN"
  value       = module.iam_final.ecs_task_role_arn
} 