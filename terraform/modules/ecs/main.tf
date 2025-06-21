// ECS Fargate module main.tf 

# 1. ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "${var.environment}-ecs-cluster"
  tags = merge(var.common_tags, {
    Name        = "${var.environment}-ecs-cluster"
    Environment = var.environment
  })
}

# 2. IAM Roles
# 2.1 Task Execution Role (for ECS agent: ECR, CloudWatch, Secrets Manager)
data "aws_iam_policy_document" "ecs_task_execution_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.environment}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 2.2 Task Role (for app: minimum permissions, can be extended)
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  name               = "${var.environment}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  tags               = var.common_tags
}

# 3. CloudWatch Log Group (if not exists)
resource "aws_cloudwatch_log_group" "ecs" {
  name              = var.log_group_name
  retention_in_days = 30
  tags              = var.common_tags
}

# 4. Task Definitions
# 4.1 Backend Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.environment}-${var.backend_service_name}-taskdef"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = templatefile("${path.module}/templates/backend_taskdef.json.tpl", {
    container_name   = var.backend_service_name
    image            = var.backend_image
    cpu              = var.backend_cpu
    memory           = var.backend_memory
    log_group        = var.log_group_name
    environment      = var.environment
    secrets_arn      = var.secrets_arn
  })
  tags = var.common_tags
}

# 4.2 Frontend Task Definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.environment}-${var.frontend_service_name}-taskdef"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = templatefile("${path.module}/templates/frontend_taskdef.json.tpl", {
    container_name   = var.frontend_service_name
    image            = var.frontend_image
    cpu              = var.frontend_cpu
    memory           = var.frontend_memory
    log_group        = var.log_group_name
    environment      = var.environment
    secrets_arn      = var.secrets_arn
  })
  tags = var.common_tags
}

# 5. ECS Services
# 5.1 Backend Service
resource "aws_ecs_service" "backend" {
  name            = "${var.environment}-${var.backend_service_name}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.backend_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  enable_execute_command = true
  tags = var.common_tags
  depends_on = [aws_cloudwatch_log_group.ecs]
}

# 5.2 Frontend Service
resource "aws_ecs_service" "frontend" {
  name            = "${var.environment}-${var.frontend_service_name}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.frontend_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  enable_execute_command = true
  tags = var.common_tags
  depends_on = [aws_cloudwatch_log_group.ecs]
} 