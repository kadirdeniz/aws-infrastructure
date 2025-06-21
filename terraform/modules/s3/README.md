# S3 Module

This module creates S3 buckets for backend and frontend storage with proper security configurations.

## Features

- **Backend and Frontend Buckets**: Separate buckets for different application components
- **Security**: Server-side encryption, public access blocking, and IAM policies
- **Versioning**: Enabled for data protection and recovery
- **Lifecycle Management**: Automatic transition to cheaper storage classes and expiration
- **Access Control**: IAM policies for ECS task access

## Usage

```hcl
module "s3" {
  source = "./modules/s3"
  
  environment        = "dev"
  project           = "my-app"
  owner             = "team"
  ecs_task_role_arn = module.iam.ecs_task_role_arn
  
  tags = {
    Environment = "dev"
    Project     = "my-app"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | n/a | yes |
| project | Project name | `string` | n/a | yes |
| owner | Owner/team name | `string` | n/a | yes |
| ecs_task_role_arn | ECS task role ARN for S3 access | `string` | n/a | yes |
| tags | Additional tags for resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| backend_bucket_name | Backend S3 bucket name |
| backend_bucket_arn | Backend S3 bucket ARN |
| frontend_bucket_name | Frontend S3 bucket name |
| frontend_bucket_arn | Frontend S3 bucket ARN |
| bucket_names | List of all S3 bucket names |
| bucket_arns | List of all S3 bucket ARNs |

## Security Features

- **Server-side encryption** with AES256
- **Public access blocking** enabled
- **Versioning** for data protection
- **IAM policies** for controlled access
- **Lifecycle policies** for cost optimization

## Cost Optimization

- Automatic transition to STANDARD_IA after 30 days
- Automatic transition to GLACIER after 90 days
- Automatic deletion after 365 days
- Versioning for data protection

## Best Practices

1. **Access Control**: Use IAM roles and policies for access control
2. **Encryption**: All data is encrypted at rest
3. **Versioning**: Enabled for data recovery
4. **Lifecycle**: Configured for cost optimization
5. **Monitoring**: Use CloudWatch for monitoring and alerting 