# ECR (Elastic Container Registry) Module

This module creates AWS ECR repositories for storing Docker container images for backend and frontend applications.

## What is ECR?

Amazon Elastic Container Registry (ECR) is a fully managed Docker container registry that makes it easy for developers to store, manage, and deploy Docker container images. ECR is integrated with Amazon ECS and provides a secure, scalable, and reliable way to store your application images.

## Why Use ECR?

- **Security**: Images are encrypted at rest and in transit
- **Integration**: Seamless integration with ECS, EKS, and other AWS services
- **Cost-effective**: Pay only for the storage you use
- **Lifecycle Management**: Automatic cleanup of old images
- **Vulnerability Scanning**: Built-in image scanning for security vulnerabilities

## What Problems Does This Module Solve?

1. **Container Image Storage**: Provides secure storage for Docker images
2. **Image Lifecycle Management**: Automatically removes old images to save costs
3. **Security**: Enables image scanning and encryption
4. **Access Control**: Integrates with IAM for fine-grained access control
5. **Environment Separation**: Creates separate repositories for different environments

## Module Features

- Creates separate repositories for backend and frontend applications
- Configurable image tag mutability (MUTABLE or IMMUTABLE)
- Automatic image scanning on push
- Encryption at rest (AES256 or KMS)
- Lifecycle policies to manage image retention
- Comprehensive tagging for resource management

## Usage

```hcl
module "ecr" {
  source = "../modules/ecr"

  backend_repository_name  = "myapp-backend"
  frontend_repository_name = "myapp-frontend"
  environment             = "dev"
  
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
| backend_repository_name | Name of the backend ECR repository | `string` | `"app-backend"` | no |
| frontend_repository_name | Name of the frontend ECR repository | `string` | `"app-frontend"` | no |
| image_tag_mutability | The tag mutability setting for the repository | `string` | `"MUTABLE"` | no |
| scan_on_push | Indicates whether images are scanned after being pushed | `bool` | `true` | no |
| encryption_type | The encryption type for the repository | `string` | `"AES256"` | no |
| max_image_count | Maximum number of images to keep in each repository | `number` | `10` | no |
| environment | Environment name (e.g., dev, prod) | `string` | `"dev"` | no |
| common_tags | Common tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| backend_repository_url | The URL of the backend repository |
| frontend_repository_url | The URL of the frontend repository |
| backend_repository_arn | The ARN of the backend repository |
| frontend_repository_arn | The ARN of the frontend repository |
| backend_repository_name | The name of the backend repository |
| frontend_repository_name | The name of the frontend repository |
| repository_urls | Map of repository names to their URLs |
| repository_arns | Map of repository names to their ARNs |

## Best Practices

1. **Use Immutable Tags**: Set `image_tag_mutability = "IMMUTABLE"` for production environments
2. **Enable Image Scanning**: Keep `scan_on_push = true` to detect vulnerabilities
3. **Lifecycle Policies**: Configure appropriate `max_image_count` to manage storage costs
4. **Environment Separation**: Use different repository names for dev/prod environments
5. **Tagging**: Apply consistent tags for resource management and cost tracking

## Alternative Options

- **Docker Hub**: Public registry, but less secure and no AWS integration
- **GitHub Container Registry**: Good for open source projects
- **Azure Container Registry**: If using Azure ecosystem
- **Google Container Registry**: If using Google Cloud Platform

## Security Considerations

- Images are encrypted at rest using AES256 (default) or KMS
- Image scanning helps detect vulnerabilities
- IAM policies control access to repositories
- Lifecycle policies prevent accumulation of old images

## Cost Considerations

- Storage costs: ~$0.10 per GB per month
- Data transfer costs apply when pulling images
- Lifecycle policies help manage storage costs
- Free tier: 500MB storage per month

## Related AWS Services

- **ECS**: Uses ECR images for container deployments
- **EKS**: Kubernetes clusters can pull from ECR
- **CodeBuild**: Can build and push images to ECR
- **CodePipeline**: Can orchestrate image building and deployment

## References

- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [ECR Best Practices](https://docs.aws.amazon.com/ecr/latest/userguide/best-practices.html)
- [ECR Lifecycle Policies](https://docs.aws.amazon.com/ecr/latest/userguide/LifecyclePolicies.html) 