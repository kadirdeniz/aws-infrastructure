# Test VPC for ECS module
module "test_vpc" {
  source = "../../../terraform/modules/vpc"
  
  vpc_cidr             = "10.0.0.0/16"
  environment          = "test"
  project              = "aws-infrastructure"
  owner                = "terraform"
  azs                  = ["eu-central-1a", "eu-central-1b"]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  tags = {
    Environment = "test"
    Module      = "ecs-test"
  }
}

# Test IAM for ECS module
module "test_iam" {
  source = "../../../terraform/modules/iam"
  
  environment = "dev"
  project     = "example"
  owner       = "test-user"
  
  # Add required parameters for IAM policies
  secrets_manager_arns = ["arn:aws:secretsmanager:eu-central-1:123456789012:secret:dev-app-credentials-*"]
  rds_cluster_arn     = "arn:aws:rds:eu-central-1:123456789012:cluster:dev-app-db"
  s3_bucket_arns      = ["arn:aws:s3:::dev-app-storage/*"]
  ecs_cluster_arn     = "arn:aws:ecs:eu-central-1:123456789012:cluster/dev-app-cluster"
}

# Security group for backend service
resource "aws_security_group" "backend" {
  name_prefix = "test-backend-"
  vpc_id      = module.test_vpc.vpc_id
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "test-backend-sg"
    Environment = "test"
    Module      = "ecs-test"
  }
}

# Security group for frontend service
resource "aws_security_group" "frontend" {
  name_prefix = "test-frontend-"
  vpc_id      = module.test_vpc.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "test-frontend-sg"
    Environment = "test"
    Module      = "ecs-test"
  }
}

# Test ECS module
module "test_ecs" {
  source = "../../../terraform/modules/ecs"
  
  vpc_id             = module.test_vpc.vpc_id
  subnet_ids         = module.test_vpc.private_subnet_ids
  security_group_ids = [aws_security_group.backend.id, aws_security_group.frontend.id]

  backend_image  = "123456789012.dkr.ecr.eu-central-1.amazonaws.com/test-backend:latest"
  frontend_image = "123456789012.dkr.ecr.eu-central-1.amazonaws.com/test-frontend:latest"

  backend_cpu    = 256
  backend_memory = 512
  frontend_cpu   = 256
  frontend_memory = 512

  backend_desired_count  = 1
  frontend_desired_count = 1

  environment = "test"

  backend_service_name  = "test-backend"
  frontend_service_name = "test-frontend"

  # Optionally, you can set log_group_name, secrets_arn, common_tags if needed
} 