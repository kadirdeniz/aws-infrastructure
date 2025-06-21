output "log_group_name" {
  description = "Name of the CloudWatch log group."
  value       = aws_cloudwatch_log_group.app.name
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard."
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "dashboard_url" {
  description = "URL to access the CloudWatch dashboard."
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "alarm_name" {
  description = "Name of the CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.example.alarm_name
} 