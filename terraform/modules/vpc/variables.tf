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

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones to use."
  type        = list(string)
}

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
} 