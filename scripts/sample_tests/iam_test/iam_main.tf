module "iam" {
  source = "../../../terraform/modules/iam"

  environment = "dev"
  project     = "example"
  owner       = "test-user"

  # Enable all roles for testing
  enable_ecs_task_execution_role = true
  enable_ecs_task_role           = true
  enable_rds_access_role         = true
  enable_api_gateway_execution_role = true

  # Test Secrets Manager ARNs (these would be real ARNs in production)
  secrets_manager_arns = [
    "arn:aws:secretsmanager:eu-central-1:123456789012:secret:dev-app-credentials-*"
  ]

  # Test S3 bucket ARNs (these would be real ARNs in production)
  s3_bucket_arns = [
    "arn:aws:s3:::dev-app-storage"
  ]

  # Test RDS cluster ARN (this would be a real ARN in production)
  rds_cluster_arn = "arn:aws:rds:eu-central-1:123456789012:cluster:dev-app-db"

  # Test ECS cluster ARN (this would be a real ARN in production)
  ecs_cluster_arn = "arn:aws:ecs:eu-central-1:123456789012:cluster/dev-app-cluster"

  tags = {
    Test = "true"
  }
} 