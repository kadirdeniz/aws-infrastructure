output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = var.enable_ecs_task_execution_role ? aws_iam_role.ecs_task_execution[0].arn : null
}

output "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role"
  value       = var.enable_ecs_task_execution_role ? aws_iam_role.ecs_task_execution[0].name : null
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = var.enable_ecs_task_role ? aws_iam_role.ecs_task[0].arn : null
}

output "ecs_task_role_name" {
  description = "Name of the ECS task role"
  value       = var.enable_ecs_task_role ? aws_iam_role.ecs_task[0].name : null
}

output "rds_access_role_arn" {
  description = "ARN of the RDS access role"
  value       = var.enable_rds_access_role ? aws_iam_role.rds_access[0].arn : null
}

output "rds_access_role_name" {
  description = "Name of the RDS access role"
  value       = var.enable_rds_access_role ? aws_iam_role.rds_access[0].name : null
}

output "api_gateway_execution_role_arn" {
  description = "ARN of the API Gateway execution role"
  value       = var.enable_api_gateway_execution_role ? aws_iam_role.api_gateway_execution[0].arn : null
}

output "api_gateway_execution_role_name" {
  description = "Name of the API Gateway execution role"
  value       = var.enable_api_gateway_execution_role ? aws_iam_role.api_gateway_execution[0].name : null
}

output "all_role_arns" {
  description = "Map of all created role ARNs"
  value = {
    ecs_task_execution_role_arn = var.enable_ecs_task_execution_role ? aws_iam_role.ecs_task_execution[0].arn : null
    ecs_task_role_arn           = var.enable_ecs_task_role ? aws_iam_role.ecs_task[0].arn : null
    rds_access_role_arn         = var.enable_rds_access_role ? aws_iam_role.rds_access[0].arn : null
    api_gateway_execution_role_arn = var.enable_api_gateway_execution_role ? aws_iam_role.api_gateway_execution[0].arn : null
  }
} 