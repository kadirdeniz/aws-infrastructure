variable "db_username" {
  description = "Test DB username"
  type        = string
}

variable "db_password" {
  description = "Test DB password"
  type        = string
  sensitive   = true
}

# Create VPC for RDS test
module "test_vpc" {
  source = "../../../terraform/modules/vpc"
  
  vpc_cidr             = "10.0.0.0/16"
  environment          = "dev"
  project              = "example"
  owner                = "test-user"
  azs                  = ["eu-central-1a", "eu-central-1b"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  tags = {
    Test = "true"
  }
}

# Create DB subnet group using VPC outputs
resource "aws_db_subnet_group" "test" {
  name       = "test-db-subnet-group"
  subnet_ids = module.test_vpc.private_subnet_ids

  tags = {
    Name        = "test-db-subnet-group"
    Environment = "dev"
    Project     = "example"
    Test        = "true"
  }
}

# Create security group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "test-rds-sg"
  vpc_id      = module.test_vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # VPC CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "test-rds-security-group"
    Environment = "dev"
    Project     = "example"
    Test        = "true"
  }
}

module "rds" {
  source                  = "../../../terraform/modules/rds"
  identifier              = "test-db"
  engine_version          = "14.12"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "testdb"
  username                = var.db_username
  password                = var.db_password
  port                    = 5432
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.test.name
  multi_az                = false
  backup_retention_period = 7
  environment             = "dev"
  project                 = "example"
  owner                   = "test-user"
  tags                    = { Test = "true" }
}

output "rds_endpoint" {
  value = module.rds.instance_endpoint
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.test.name
}

output "security_group_id" {
  value = aws_security_group.rds.id
} 