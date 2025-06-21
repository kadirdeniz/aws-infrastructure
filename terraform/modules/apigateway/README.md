# API Gateway Terraform Module

This module provisions an AWS API Gateway (HTTP API) for routing traffic to backend and frontend ECS services. It supports CORS, HTTPS, and environment-based configuration.

## Features
- HTTP API Gateway with CORS enabled
- Routes `/api/*` to backend, all others to frontend
- Integrates with ECS Fargate services (or any HTTP endpoint)
- HTTPS enforced by default
- Environment-based naming and tagging

## Usage Example
```hcl
module "apigateway" {
  source      = "./modules/apigateway"
  api_name    = "myapp-${var.environment}-api"
  backend_url = module.ecs.backend_service_url
  frontend_url = module.ecs.frontend_service_url
  environment = var.environment
  common_tags = local.common_tags
}
```

## Variables
| Name         | Type         | Description                                 |
|--------------|--------------|---------------------------------------------|
| api_name     | string       | Name of the API Gateway API                 |
| backend_url  | string       | URL of backend ECS service                  |
| frontend_url | string       | URL of frontend ECS service                 |
| environment  | string       | Deployment environment (dev/prod)           |
| common_tags  | map(string)  | Common tags for all resources               |

## Outputs
| Name         | Description                         |
|--------------|-------------------------------------|
| api_endpoint | Invoke URL of the API Gateway       |
| api_id       | ID of the API Gateway               |
| stage_name   | Name of the deployed stage          |

## Best Practices
- Use HTTPS endpoints for backend/frontend integrations
- Restrict access with IAM or usage plans if needed
- Use environment-specific names for all resources
- Monitor API Gateway with CloudWatch

## References
- [AWS API Gateway HTTP API Docs](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api.html)
- [Terraform AWS API Gateway v2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) 