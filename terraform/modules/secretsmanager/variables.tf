variable "secret_name" {
  description = "Name of the secret in AWS Secrets Manager."
  type        = string
}

variable "secret_description" {
  description = "Description of the secret."
  type        = string
  default     = "Application credentials and configuration"
}

variable "recovery_window_in_days" {
  description = "Number of days to wait before deleting the secret (0 for immediate deletion)."
  type        = number
  default     = 7
}

variable "db_host" {
  description = "Database host endpoint."
  type        = string
}

variable "db_port" {
  description = "Database port number."
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Database name."
  type        = string
}

variable "db_username" {
  description = "Database username."
  type        = string
}

variable "db_password" {
  description = "Database password."
  type        = string
  sensitive   = true
}

variable "s3_backend_bucket_name" {
  description = "Backend S3 bucket name."
  type        = string
  default     = ""
}

variable "s3_frontend_bucket_name" {
  description = "Frontend S3 bucket name."
  type        = string
  default     = ""
}

variable "s3_backend_bucket_arn" {
  description = "Backend S3 bucket ARN."
  type        = string
  default     = ""
}

variable "s3_frontend_bucket_arn" {
  description = "Frontend S3 bucket ARN."
  type        = string
  default     = ""
}

variable "api_keys" {
  description = "Map of API key names to values."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "enable_rotation" {
  description = "Enable automatic secret rotation."
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "project" {
  description = "Project name."
  type        = string
}

variable "owner" {
  description = "Owner/team name."
  type        = string
}

variable "tags" {
  description = "Additional tags for resources."
  type        = map(string)
  default     = {}
}

variable "create_api_keys_secret" {
  description = "Whether to create a separate secret for API keys."
  type        = bool
  default     = false
}

variable "api_key_1" {
  description = "First API key value."
  type        = string
  default     = ""
  sensitive   = true
}

variable "api_key_2" {
  description = "Second API key value."
  type        = string
  default     = ""
  sensitive   = true
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
} 