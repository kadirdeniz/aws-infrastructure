output "secret_arn" {
  description = "ARN of the main application secret."
  value       = aws_secretsmanager_secret.app_credentials.arn
}

output "secret_name" {
  description = "Name of the main application secret."
  value       = aws_secretsmanager_secret.app_credentials.name
}

output "api_keys_secret_arn" {
  description = "ARN of the API keys secret (if created)."
  value       = var.create_api_keys_secret ? aws_secretsmanager_secret.api_keys[0].arn : null
}

output "api_keys_secret_name" {
  description = "Name of the API keys secret (if created)."
  value       = var.create_api_keys_secret ? aws_secretsmanager_secret.api_keys[0].name : null
} 