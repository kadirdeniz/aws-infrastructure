# RDS PostgreSQL Module

This module provisions a minimal-cost, production-ready Amazon RDS PostgreSQL instance in a private subnet, following best practices for security, modularity, and tagging.

## Features
- Creates a PostgreSQL RDS instance (default: free tier `db.t3.micro`)
- Deploys in private subnets (no public access)
- Supports custom subnet group and security groups
- All credentials are passed as variables (no hardcoding)
- Tags all resources with environment, project, owner, and custom tags
- Ready for integration with AWS Secrets Manager (future step)

## Usage
```hcl
module "rds" {
  source                  = "../modules/rds"
  identifier              = "myapp-dev-db"
  engine_version          = "15.5"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "appdb"
  username                = var.db_username
  password                = var.db_password
  port                    = 5432
  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = aws_db_subnet_group.db.name
  multi_az                = false
  backup_retention_period = 7
  environment             = var.environment
  project                 = var.project
  owner                   = var.owner
  tags                    = { Test = "true" }
}
```

## Inputs
See `variables.tf` for all input variables and descriptions.

## Outputs
- `instance_endpoint`: The connection endpoint for the RDS instance
- `instance_arn`: The ARN of the RDS instance
- `db_name`: The database name

## Best Practices
- Never hardcode credentials. Use environment variables or secret managers.
- Place RDS in private subnets for security.
- Use IAM and security groups to restrict access.
- Enable backups and encryption.
- Use tagging for cost allocation and resource management.

## Next Steps
- Integrate with AWS Secrets Manager for password management and rotation.
- Add monitoring and alerting (CloudWatch).

## References
- [AWS RDS + Secrets Manager Integration](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-secrets-manager.html)
- [Terraform AWS RDS Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) 