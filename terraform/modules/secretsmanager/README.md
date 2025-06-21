# AWS Secrets Manager Terraform Module

This module provisions AWS Secrets Manager resources for securely storing and managing application credentials, database connection strings, and API keys. It supports automatic password generation and JSON format secrets.

## Features
- Secure password generation using random_password
- JSON format secrets for database credentials
- Optional API keys secret creation
- Environment-based naming and tagging
- Configurable recovery window

## Usage Example
```hcl
module "secretsmanager" {
  source                    = "./modules/secretsmanager"
  secret_name              = "myapp-${var.environment}-credentials"
  secret_description       = "Database credentials for ${var.environment} environment"
  db_host                  = module.rds.db_endpoint
  db_port                  = 5432
  db_name                  = "myappdb"
  db_username              = "appuser"
  create_api_keys_secret   = true
  api_key_1                = var.api_key_1
  api_key_2                = var.api_key_2
  recovery_window_in_days  = 7
  common_tags              = local.common_tags
}
```

## Variables
| Name                    | Type         | Description                                 |
|-------------------------|--------------|---------------------------------------------|
| secret_name             | string       | Name of the secret in AWS Secrets Manager   |
| secret_description      | string       | Description of the secret                   |
| recovery_window_in_days | number       | Days to wait before deleting secret         |
| db_host                 | string       | Database host endpoint                      |
| db_port                 | number       | Database port number                        |
| db_name                 | string       | Database name                               |
| db_username             | string       | Database username                           |
| create_api_keys_secret  | bool         | Whether to create API keys secret           |
| api_key_1               | string       | First API key value (sensitive)             |
| api_key_2               | string       | Second API key value (sensitive)            |
| common_tags             | map(string)  | Common tags for all resources               |

## Outputs
| Name                | Description                                 |
|---------------------|---------------------------------------------|
| secret_arn          | ARN of the main application secret          |
| secret_name         | Name of the main application secret         |
| api_keys_secret_arn | ARN of the API keys secret (if created)     |
| api_keys_secret_name| Name of the API keys secret (if created)    |

## Best Practices
- Use environment-specific secret names
- Set appropriate recovery window (0 for dev, 7-30 for prod)
- Never expose sensitive values in outputs
- Use IAM policies to control access to secrets
- Rotate secrets regularly using AWS Secrets Manager rotation

## Secret Format
The main secret is stored as JSON with the following structure:
```json
{
  "host": "db-endpoint.amazonaws.com",
  "port": 5432,
  "dbname": "myappdb",
  "username": "appuser",
  "password": "generated-password"
}
```

## References
- [AWS Secrets Manager Documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html)
- [Terraform AWS Secrets Manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)
- [Manage Secrets in AWS Secrets Manager with Terraform](https://medium.com/@karan1902/manage-secrets-in-aws-secrets-manager-with-terraform-bfdbc5aae257) 