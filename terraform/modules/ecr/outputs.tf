output "backend_repository_url" {
  description = "The URL of the backend repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_repository_url" {
  description = "The URL of the frontend repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_repository_arn" {
  description = "The ARN of the backend repository"
  value       = aws_ecr_repository.backend.arn
}

output "frontend_repository_arn" {
  description = "The ARN of the frontend repository"
  value       = aws_ecr_repository.frontend.arn
}

output "backend_repository_name" {
  description = "The name of the backend repository"
  value       = aws_ecr_repository.backend.name
}

output "frontend_repository_name" {
  description = "The name of the frontend repository"
  value       = aws_ecr_repository.frontend.name
}

output "repository_urls" {
  description = "Map of repository names to their URLs"
  value = {
    backend  = aws_ecr_repository.backend.repository_url
    frontend = aws_ecr_repository.frontend.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to their ARNs"
  value = {
    backend  = aws_ecr_repository.backend.arn
    frontend = aws_ecr_repository.frontend.arn
  }
} 