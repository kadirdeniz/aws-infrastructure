# ECS Fargate Module

This module creates AWS ECS Fargate services for backend and frontend containers with best practices for security, scalability, and cost efficiency.

## What is ECS Fargate?

Amazon Elastic Container Service (ECS) Fargate is a serverless compute engine that allows you to run containers without managing servers. Fargate eliminates the need to provision and manage EC2 instances, making it ideal for containerized applications.

## Features

- **Serverless**: No EC2 instances to manage
- **Auto-scaling**: Built-in scaling capabilities
- **Security**: IAM roles, security groups, private subnets
- **Logging**: CloudWatch integration
- **Secrets**: AWS Secrets Manager integration
- **Cost-effective**: Pay only for resources used

## Usage

```hcl
module "ecs" {
  source = "../modules/ecs"

  # Network configuration
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.vpc.ecs_security_group_id]

  # Container images
  backend_image  = "123456789012.dkr.ecr.us-east-1.amazonaws.com/app-backend:latest"
  frontend_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/app-frontend:latest"

  # Resource allocation
  backend_cpu    = 256
  backend_memory = 512
  frontend_cpu   = 256
  frontend_memory = 512

  # Service configuration
  backend_desired_count  = 2
  frontend_desired_count = 2

  # Environment
  environment = "dev"
  
  # Optional secrets
  secrets_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:app-secrets"

  common_tags = {
    Project     = "myapp"
    Owner       = "devops"
    Environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | VPC ID for ECS services | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for ECS services | `list(string)` | n/a | yes |
| security_group_ids | List of security group IDs for ECS services | `list(string)` | n/a | yes |
| backend_image | ECR image URI for backend service | `string` | n/a | yes |
| frontend_image | ECR image URI for frontend service | `string` | n/a | yes |
| backend_cpu | CPU units for backend task | `number` | `256` | no |
| backend_memory | Memory (MB) for backend task | `number` | `512` | no |
| frontend_cpu | CPU units for frontend task | `number` | `256` | no |
| frontend_memory | Memory (MB) for frontend task | `number` | `512` | no |
| backend_desired_count | Desired number of backend ECS tasks | `number` | `1` | no |
| frontend_desired_count | Desired number of frontend ECS tasks | `number` | `1` | no |
| environment | Environment name | `string` | `"dev"` | no |
| secrets_arn | ARN of AWS Secrets Manager secret | `string` | `""` | no |
| log_group_name | CloudWatch log group name | `string` | `"/ecs/app"` | no |
| common_tags | Common tags for all resources | `map(string)` | `{}` | no |
| backend_service_name | Name for backend ECS service | `string` | `"backend"` | no |
| frontend_service_name | Name for frontend ECS service | `string` | `"frontend"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ECS cluster ID |
| cluster_name | ECS cluster name |
| backend_service_name | Backend ECS service name |
| backend_service_arn | Backend ECS service ARN |
| frontend_service_name | Frontend ECS service name |
| frontend_service_arn | Frontend ECS service ARN |
| backend_taskdef_family | Backend task definition family |
| backend_taskdef_arn | Backend task definition ARN |
| frontend_taskdef_family | Frontend task definition family |
| frontend_taskdef_arn | Frontend task definition ARN |
| task_execution_role_arn | ECS task execution role ARN |
| task_role_arn | ECS task role ARN |
| log_group_name | CloudWatch log group name |

## Port Configuration

- **Backend**: Port 8080 (configurable in task definition template)
- **Frontend**: Port 80 (configurable in task definition template)

## Security Features

- **Private subnets**: Services run in private subnets
- **IAM roles**: Separate execution and task roles
- **Security groups**: Configurable network access
- **Secrets integration**: AWS Secrets Manager support
- **Log encryption**: CloudWatch logs with encryption

## Best Practices

1. **Resource sizing**: Start with minimal CPU/memory and scale as needed
2. **Security**: Use private subnets and restrictive security groups
3. **Secrets**: Store sensitive data in AWS Secrets Manager
4. **Logging**: Enable CloudWatch logging for monitoring
5. **Tags**: Use consistent tagging for cost tracking
6. **Scaling**: Configure auto-scaling based on metrics

## Cost Considerations

- **Fargate pricing**: Pay per vCPU and memory
- **Free tier**: 50 hours/month for Fargate
- **Optimization**: Right-size CPU and memory
- **Scaling**: Use auto-scaling to optimize costs

## Related AWS Services

- **ECR**: Container image storage
- **CloudWatch**: Logging and monitoring
- **Secrets Manager**: Credential management
- **VPC**: Network isolation
- **IAM**: Access control

## References

- [AWS ECS Fargate Documentation](https://docs.aws.amazon.com/ecs/latest/userguide/what-is-fargate.html)
- [ECS Task Definition Parameters](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-definition-template.html)
- [ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [Fargate Pricing](https://aws.amazon.com/fargate/pricing/) 