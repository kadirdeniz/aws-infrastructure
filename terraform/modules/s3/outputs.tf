output "backend_bucket_name" {
  description = "Backend S3 bucket name"
  value       = aws_s3_bucket.backend_bucket.bucket
}

output "backend_bucket_arn" {
  description = "Backend S3 bucket ARN"
  value       = aws_s3_bucket.backend_bucket.arn
}

output "frontend_bucket_name" {
  description = "Frontend S3 bucket name"
  value       = aws_s3_bucket.frontend_bucket.bucket
}

output "frontend_bucket_arn" {
  description = "Frontend S3 bucket ARN"
  value       = aws_s3_bucket.frontend_bucket.arn
}

output "bucket_names" {
  description = "List of all S3 bucket names"
  value       = [aws_s3_bucket.backend_bucket.bucket, aws_s3_bucket.frontend_bucket.bucket]
}

output "bucket_arns" {
  description = "List of all S3 bucket ARNs"
  value       = [aws_s3_bucket.backend_bucket.arn, aws_s3_bucket.frontend_bucket.arn]
} 