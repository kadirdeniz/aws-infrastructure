variable "log_group_name" {
  description = "Name of the CloudWatch log group."
  type        = string
}

variable "log_retention_days" {
  description = "Retention period for log group (in days)."
  type        = number
  default     = 30
}

variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard."
  type        = string
}

variable "aws_region" {
  description = "AWS region for dashboard widgets."
  type        = string
}

variable "alarm_name" {
  description = "Name of the CloudWatch alarm."
  type        = string
  default     = "example-log-alarm"
}

variable "alarm_threshold" {
  description = "Threshold for the CloudWatch alarm."
  type        = number
  default     = 1000
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
} 