variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}

variable "project" {
  description = "Project name for resource tagging"
  type        = string
  default     = "example"
}

variable "owner" {
  description = "Owner name for resource tagging"
  type        = string
  default     = "test-user"
}

variable "enable_ecs_task_execution_role" {
  description = "Whether to create the ECS task execution role"
  type        = bool
  default     = true
}

variable "enable_ecs_task_role" {
  description = "Whether to create the ECS task role"
  type        = bool
  default     = true
}

variable "enable_rds_access_role" {
  description = "Whether to create the RDS access role"
  type        = bool
  default     = true
}

variable "enable_api_gateway_execution_role" {
  description = "Whether to create the API Gateway execution role"
  type        = bool
  default     = true
}

variable "secrets_manager_arns" {
  description = "List of Secrets Manager ARNs that ECS tasks can access"
  type        = list(string)
  default     = []
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs that ECS tasks can access"
  type        = list(string)
  default     = []
}

variable "rds_cluster_arn" {
  description = "ARN of the RDS cluster for access permissions"
  type        = string
  default     = ""
}

variable "ecs_cluster_arn" {
  description = "ARN of the ECS cluster for API Gateway permissions"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
} 