variable "backend_repository_name" {
  description = "Name of the backend ECR repository"
  type        = string
  default     = "app-backend"
}

variable "frontend_repository_name" {
  description = "Name of the frontend ECR repository"
  type        = string
  default     = "app-frontend"
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE"
  type        = string
  default     = "MUTABLE"
  
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "The encryption type for the repository. Must be one of: AES256 or KMS"
  type        = string
  default     = "AES256"
  
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Encryption type must be either AES256 or KMS."
  }
}

variable "max_image_count" {
  description = "Maximum number of images to keep in each repository"
  type        = number
  default     = 10
  
  validation {
    condition     = var.max_image_count > 0 && var.max_image_count <= 100
    error_message = "Max image count must be between 1 and 100."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
} 