variable "api_name" {
  description = "Name of the API Gateway API."
  type        = string
}

variable "backend_url" {
  description = "URL of the backend ECS service (load balancer or service endpoint)."
  type        = string
}

variable "frontend_url" {
  description = "URL of the frontend ECS service (load balancer or service endpoint)."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev or prod)."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
} 