variable "identifier" {
  description = "The name of the RDS instance."
  type        = string
}

variable "engine_version" {
  description = "The version of the PostgreSQL engine."
  type        = string
  default     = "15.5"
}

variable "instance_class" {
  description = "The instance type of the RDS instance."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "The name of the database to create."
  type        = string
}

variable "username" {
  description = "Username for the master DB user."
  type        = string
}

variable "password" {
  description = "Password for the master DB user."
  type        = string
  sensitive   = true
}

variable "port" {
  description = "The port on which the DB accepts connections."
  type        = number
  default     = 5432
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate."
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "Subnet group for the RDS instance."
  type        = string
}

variable "multi_az" {
  description = "If true, deploy a Multi-AZ RDS instance."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The days to retain backups for."
  type        = number
  default     = 7
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "project" {
  description = "Project name for resource naming and tagging"
  type        = string
}

variable "owner" {
  description = "Owner name for resource tagging"
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
} 