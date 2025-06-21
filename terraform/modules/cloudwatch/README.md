# CloudWatch Terraform Module

This module provisions AWS CloudWatch resources for logging, monitoring, and alerting. It creates a log group, a dashboard with widgets, and an example metric alarm.

## Features
- CloudWatch log group for application/service logs
- CloudWatch dashboard with sample widgets
- Example metric alarm for log events
- Environment-based naming and tagging

## Usage Example
```hcl
module "cloudwatch" {
  source            = "./modules/cloudwatch"
  log_group_name    = "myapp-dev-logs"
  log_retention_days = 30
  dashboard_name    = "myapp-dev-dashboard"
  aws_region        = var.aws_region
  alarm_name        = "myapp-dev-log-alarm"
  alarm_threshold   = 1000
  common_tags       = local.common_tags
}
```

## Variables
| Name              | Type         | Description                                 |
|-------------------|--------------|---------------------------------------------|
| log_group_name    | string       | Name of the CloudWatch log group            |
| log_retention_days| number       | Retention period for log group (days)       |
| dashboard_name    | string       | Name of the CloudWatch dashboard            |
| aws_region        | string       | AWS region for dashboard widgets            |
| alarm_name        | string       | Name of the CloudWatch alarm                |
| alarm_threshold   | number       | Threshold for the CloudWatch alarm          |
| common_tags       | map(string)  | Common tags for all resources               |

## Outputs
| Name           | Description                                 |
|----------------|---------------------------------------------|
| log_group_name | Name of the CloudWatch log group            |
| dashboard_name | Name of the CloudWatch dashboard            |
| dashboard_url  | URL to access the CloudWatch dashboard      |
| alarm_name     | Name of the CloudWatch alarm                |

## Best Practices
- Use log group names that include environment and service
- Set appropriate log retention for cost control
- Add widgets to the dashboard for key metrics and alarms
- Use alarms to monitor critical metrics and trigger notifications

## References
- [AWS CloudWatch Dashboard Docs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Dashboards.html)
- [Terraform AWS CloudWatch Dashboard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard)
- [Terraform AWS CloudWatch Log Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) 