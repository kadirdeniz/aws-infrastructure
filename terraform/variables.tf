// Define input variables for the root Terraform configuration here. 

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "aws-infrastructure"
}

variable "owner" {
  description = "Owner/team name"
  type        = string
  default     = "terraform"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "db_username" {
  description = "RDS database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "RDS database name"
  type        = string
  default     = "appdb"
}

variable "backend_image" {
  description = "Backend Docker image URI"
  type        = string
  default     = "nginx:alpine"
}

variable "frontend_image" {
  description = "Frontend Docker image URI"
  type        = string
  default     = "nginx:alpine"
}

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms"
  type        = bool
  default     = true
}

variable "enable_secrets_rotation" {
  description = "Enable automatic secrets rotation"
  type        = bool
  default     = false
} 