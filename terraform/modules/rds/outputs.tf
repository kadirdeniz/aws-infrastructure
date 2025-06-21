output "instance_endpoint" {
  description = "The connection endpoint for the RDS instance."
  value       = aws_db_instance.this.endpoint
}

output "instance_arn" {
  description = "The ARN of the RDS instance."
  value       = aws_db_instance.this.arn
}

output "db_name" {
  description = "The database name."
  value       = aws_db_instance.this.db_name
} 