locals {
  common_tags = merge({
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "terraform"
  }, var.tags)

  name_prefix = "${var.environment}-${var.project}"
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution" {
  count = var.enable_ecs_task_execution_role ? 1 : 0

  name = "${local.name_prefix}-ecs-task-execution-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count = var.enable_ecs_task_execution_role ? 1 : 0

  role       = aws_iam_role.ecs_task_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for Secrets Manager access
resource "aws_iam_policy" "ecs_task_execution_secrets" {
  count = var.enable_ecs_task_execution_role && length(var.secrets_manager_arns) > 0 ? 1 : 0

  name        = "${local.name_prefix}-ecs-task-execution-secrets-policy"
  description = "Policy for ECS task execution role to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.secrets_manager_arns
        Condition = {
          StringEquals = {
            "aws:RequestTag/Environment" = var.environment
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_secrets" {
  count = var.enable_ecs_task_execution_role && length(var.secrets_manager_arns) > 0 ? 1 : 0

  role       = aws_iam_role.ecs_task_execution[0].name
  policy_arn = aws_iam_policy.ecs_task_execution_secrets[0].arn
}

# ECS Task Role
resource "aws_iam_role" "ecs_task" {
  count = var.enable_ecs_task_role ? 1 : 0

  name = "${local.name_prefix}-ecs-task-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Custom policy for ECS task role (application permissions)
resource "aws_iam_policy" "ecs_task_app" {
  count = var.enable_ecs_task_role ? 1 : 0

  name        = "${local.name_prefix}-ecs-task-app-policy"
  description = "Policy for ECS task role application permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.secrets_manager_arns
        Condition = {
          StringEquals = {
            "aws:RequestTag/Environment" = var.environment
          }
        }
      }
    ], length(var.s3_bucket_arns) > 0 ? [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [for bucket in var.s3_bucket_arns : "${bucket}/*"]
      }
    ] : [])
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_app" {
  count = var.enable_ecs_task_role ? 1 : 0

  role       = aws_iam_role.ecs_task[0].name
  policy_arn = aws_iam_policy.ecs_task_app[0].arn
}

# RDS Access Role
resource "aws_iam_role" "rds_access" {
  count = var.enable_rds_access_role ? 1 : 0

  name = "${local.name_prefix}-rds-access-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Custom policy for RDS access
resource "aws_iam_policy" "rds_access" {
  count = var.enable_rds_access_role ? 1 : 0

  name        = "${local.name_prefix}-rds-access-policy"
  description = "Policy for RDS access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.secrets_manager_arns
        Condition = {
          StringEquals = {
            "aws:RequestTag/Environment" = var.environment
          }
        }
      }
    ], var.rds_cluster_arn != "" ? [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = var.rds_cluster_arn
        Condition = {
          StringEquals = {
            "aws:RequestTag/Environment" = var.environment
          }
        }
      }
    ] : [])
  })
}

resource "aws_iam_role_policy_attachment" "rds_access" {
  count = var.enable_rds_access_role ? 1 : 0

  role       = aws_iam_role.rds_access[0].name
  policy_arn = aws_iam_policy.rds_access[0].arn
}

# API Gateway Execution Role
resource "aws_iam_role" "api_gateway_execution" {
  count = var.enable_api_gateway_execution_role ? 1 : 0

  name = "${local.name_prefix}-api-gateway-execution-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Custom policy for API Gateway execution
resource "aws_iam_policy" "api_gateway_execution" {
  count = var.enable_api_gateway_execution_role ? 1 : 0

  name        = "${local.name_prefix}-api-gateway-execution-policy"
  description = "Policy for API Gateway execution"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ], var.ecs_cluster_arn != "" ? [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks"
        ]
        Resource = var.ecs_cluster_arn
        Condition = {
          StringEquals = {
            "aws:RequestTag/Environment" = var.environment
          }
        }
      }
    ] : [])
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_execution" {
  count = var.enable_api_gateway_execution_role ? 1 : 0

  role       = aws_iam_role.api_gateway_execution[0].name
  policy_arn = aws_iam_policy.api_gateway_execution[0].arn
} 