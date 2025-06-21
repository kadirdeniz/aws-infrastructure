# IAM Module

## Overview
This module creates AWS Identity and Access Management (IAM) roles and policies required for the serverless infrastructure. It follows the principle of least privilege and provides secure access for ECS tasks, RDS, and other AWS services.

## What is IAM?
AWS Identity and Access Management (IAM) is a web service that helps you securely control access to AWS resources. It enables you to create and manage AWS users and groups, and use permissions to allow and deny their access to AWS resources.

## Why is IAM used in this project?
- **Security**: Provides secure, granular access control to AWS resources
- **Least Privilege**: Ensures services only have the minimum permissions they need
- **Compliance**: Helps meet security and compliance requirements
- **Auditability**: Provides detailed logs of who accessed what and when

## What problems does IAM solve?
1. **Unauthorized Access**: Prevents unauthorized users from accessing AWS resources
2. **Over-privileged Access**: Ensures services don't have more permissions than necessary
3. **Credential Management**: Provides temporary credentials for services instead of long-term access keys
4. **Cross-Service Access**: Enables secure communication between AWS services

## Alternative Options and Rationale
- **AWS Organizations**: For multi-account management (not needed for single-account setup)
- **AWS SSO**: For user authentication (not needed for service-to-service communication)
- **Custom Policies**: We use AWS managed policies where possible and create custom policies only when necessary

## IAM Components Created

### 1. ECS Task Execution Role
- **Purpose**: Allows ECS to pull container images from ECR and write logs to CloudWatch
- **Permissions**: 
  - ECR read access
  - CloudWatch Logs write access
  - Secrets Manager read access (for application credentials)

### 2. ECS Task Role
- **Purpose**: Provides permissions for the application running inside the container
- **Permissions**:
  - Secrets Manager read access (for database credentials)
  - S3 access (if needed for file storage)
  - Any other application-specific permissions

### 3. RDS Access Role
- **Purpose**: Allows ECS tasks to connect to RDS database
- **Permissions**:
  - RDS connect permissions
  - Secrets Manager read access for database credentials

### 4. API Gateway Execution Role
- **Purpose**: Allows API Gateway to invoke ECS services
- **Permissions**:
  - ECS task execution permissions
  - CloudWatch Logs write access

## Best Practices Implemented
- **Principle of Least Privilege**: Each role has only the minimum required permissions
- **AWS Managed Policies**: Used where possible to reduce maintenance overhead
- **Resource-Level Permissions**: Permissions are scoped to specific resources where applicable
- **Conditional Permissions**: Added conditions to restrict access based on tags or other criteria
- **No Hardcoded Credentials**: All sensitive data is managed through Secrets Manager

## Caveats and Considerations
- **Permission Changes**: Adding new permissions requires careful review to maintain security
- **Cross-Region Access**: Ensure roles work across all regions where resources are deployed
- **Service Limits**: Be aware of IAM service limits (roles per account, policies per role, etc.)
- **Audit Trail**: Enable CloudTrail to monitor IAM usage and detect unauthorized access

## Usage

### Variables
```hcl
module "iam" {
  source = "./modules/iam"
  
  environment = "dev"
  project     = "example"
  owner       = "test-user"
  
  # ECS Task Execution Role
  enable_ecs_task_execution_role = true
  
  # ECS Task Role
  enable_ecs_task_role = true
  
  # RDS Access Role
  enable_rds_access_role = true
  
  # API Gateway Execution Role
  enable_api_gateway_execution_role = true
}
```

### Outputs
- `ecs_task_execution_role_arn`: ARN of the ECS task execution role
- `ecs_task_role_arn`: ARN of the ECS task role
- `rds_access_role_arn`: ARN of the RDS access role
- `api_gateway_execution_role_arn`: ARN of the API Gateway execution role

## Environment Variables
No environment variables are required for this module as it only creates IAM resources with no sensitive data.

## Security Notes
- All IAM roles use temporary credentials (no long-term access keys)
- Permissions are scoped to specific resources and actions
- CloudTrail logging is recommended for audit purposes
- Regular permission reviews should be conducted 