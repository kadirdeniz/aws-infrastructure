resource "aws_cloudwatch_log_group" "app" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.dashboard_name
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x = 0
        y = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Logs", "IncomingLogEvents", "LogGroupName", var.log_group_name]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Log Events - ${var.log_group_name}"
        }
      },
      {
        type = "text"
        x = 0
        y = 7
        width = 6
        height = 3
        properties = {
          markdown = "# CloudWatch Dashboard\nThis dashboard is managed by Terraform."
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "example" {
  alarm_name          = var.alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "IncomingLogEvents"
  namespace           = "AWS/Logs"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alarm_threshold
  alarm_description   = "Alarm when log events exceed threshold."
  dimensions = {
    LogGroupName = var.log_group_name
  }
  actions_enabled = false
} 