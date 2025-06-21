module "cloudwatch" {
  source            = "../../../terraform/modules/cloudwatch"
  log_group_name    = "test-app-logs"
  log_retention_days = 7
  dashboard_name    = "test-app-dashboard"
  aws_region        = "eu-central-1"
  alarm_name        = "test-app-log-alarm"
  alarm_threshold   = 10
  common_tags = {
    Environment = "test"
    Module      = "cloudwatch-test"
  }
}

output "dashboard_url" {
  value = module.cloudwatch.dashboard_url
} 