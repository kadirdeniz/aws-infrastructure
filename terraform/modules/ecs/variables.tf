// ECS Fargate module variables.tf 

variable "vpc_id" {
  description = "VPC ID for ECS services"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS services"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for ECS services"
  type        = list(string)
}

variable "backend_image" {
  description = "ECR image URI for backend service"
  type        = string
}

variable "frontend_image" {
  description = "ECR image URI for frontend service"
  type        = string
}

variable "backend_cpu" {
  description = "CPU units for backend task (e.g., 256, 512)"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Memory (MB) for backend task (e.g., 512, 1024)"
  type        = number
  default     = 512
}

variable "frontend_cpu" {
  description = "CPU units for frontend task (e.g., 256, 512)"
  type        = number
  default     = 256
}

variable "frontend_memory" {
  description = "Memory (MB) for frontend task (e.g., 512, 1024)"
  type        = number
  default     = 512
}

variable "backend_desired_count" {
  description = "Desired number of backend ECS tasks"
  type        = number
  default     = 1
}

variable "frontend_desired_count" {
  description = "Desired number of frontend ECS tasks"
  type        = number
  default     = 1
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "secrets_arn" {
  description = "ARN of the AWS Secrets Manager secret for credentials (optional)"
  type        = string
  default     = ""
}

variable "log_group_name" {
  description = "CloudWatch log group name for ECS tasks"
  type        = string
  default     = "/ecs/app"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "backend_service_name" {
  description = "Name for the backend ECS service"
  type        = string
  default     = "backend"
}

variable "frontend_service_name" {
  description = "Name for the frontend ECS service"
  type        = string
  default     = "frontend"
} 