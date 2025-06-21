// ECS Fargate module outputs.tf 

output "cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

output "backend_service_name" {
  description = "Backend ECS service name"
  value       = aws_ecs_service.backend.name
}

output "backend_service_arn" {
  description = "Backend ECS service ARN"
  value       = aws_ecs_service.backend.id
}

output "frontend_service_name" {
  description = "Frontend ECS service name"
  value       = aws_ecs_service.frontend.name
}

output "frontend_service_arn" {
  description = "Frontend ECS service ARN"
  value       = aws_ecs_service.frontend.id
}

output "backend_taskdef_family" {
  description = "Backend task definition family"
  value       = aws_ecs_task_definition.backend.family
}

output "backend_taskdef_arn" {
  description = "Backend task definition ARN"
  value       = aws_ecs_task_definition.backend.arn
}

output "frontend_taskdef_family" {
  description = "Frontend task definition family"
  value       = aws_ecs_task_definition.frontend.family
}

output "frontend_taskdef_arn" {
  description = "Frontend task definition ARN"
  value       = aws_ecs_task_definition.frontend.arn
}

output "task_execution_role_arn" {
  description = "ECS task execution role ARN"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "task_role_arn" {
  description = "ECS task role ARN"
  value       = aws_iam_role.ecs_task.arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.ecs.name
} 