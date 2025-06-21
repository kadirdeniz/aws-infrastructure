variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "owner" {
  description = "Owner/team name"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ECS task role ARN for S3 access"
  type        = string
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
} 