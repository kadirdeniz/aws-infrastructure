# Project Workflow

This document describes the step-by-step workflow for building and deploying the minimal-cost, open-source AWS serverless infrastructure using Terraform, ECS Fargate, RDS PostgreSQL, Secrets Manager, API Gateway, and GitHub Actions.

## 1. Infrastructure as Code (Terraform) Foundations
- Define VPC, subnets, and security groups for network isolation and security.
- Create IAM roles and policies with least privilege for all services.
- Provision RDS PostgreSQL in a private subnet.
- Create ECR repositories for backend and frontend container images.

## 2. Modular Service Implementation
- For each infrastructure service (e.g., RDS, VPC, ECS), create a dedicated module folder under `modules/` (e.g., `modules/rds/`) **only when that service is being implemented**.
- Each module must include its own `main.tf`, `variables.tf`, `outputs.tf`, and a `README.md` documenting the service.
- Complete and document each service before moving to the next. Do not create all service folders at once.
- **After creating each module, test it in isolation before moving to the next service.**

## 2.1. Module Testing and Validation (NEW)
- After implementing a module:
  - Create a minimal root configuration (in `terraform/main.tf`) that calls the new module with example variable values.
  - Use a `.env` file or `terraform.tfvars` for non-sensitive test values. For sensitive values (e.g., secret ARNs), use environment variables or mock/test secrets.
  - Run `terraform init`, `terraform plan`, and (optionally) `terraform apply` to verify the module works as expected.
  - Check that outputs are correct and resources are provisioned as intended.
  - Destroy test resources after validation with `terraform destroy`.
- Only after successful testing and validation should you proceed to the next service/module.

## 3. Environment Variable and Secrets Management
- **No credentials or sensitive values are ever hardcoded in code, Dockerfiles, Terraform, or pipeline scripts.**
- All configuration and credentials are provided via environment variables or AWS Secrets Manager.
- **Environment variables for Terraform are managed using a `.env` file for local development.**
  - The `.env` file is loaded into the shell before running Terraform commands (e.g., `export $(grep -v '^#' .env | xargs)`).
  - Terraform reads variables from the shell if they are prefixed with `TF_VAR_` (e.g., `TF_VAR_db_username`).
  - The `.env` file is not read by Terraform directly.
  - For CI/CD, environment variables are set in the pipeline configuration or secret manager.
  - Sensitive values must never be committed; a `.env.example` file must be provided as a template.
- Each environment (dev, prod) must have its own `.env` file (not committed), and a sample `.env.example` must be provided.
- Environment variables are loaded at runtime, not at build time.
- For sensitive values (e.g., RDS credentials), env files only contain the Secrets Manager secret name or ARN. The actual secrets are fetched at runtime by the application or injected into ECS tasks via the `secrets` block in the task definition.
- Switching between environments is as simple as changing the env file or the secret name/ARN.
- `.gitignore` must include `.env`, `*.tfvars`, and any other sensitive config files.

## 4. ECS Fargate Cluster and Services
- Define ECS cluster and task definitions for backend and frontend containers.
- Configure minimal resources (CPU, memory) for cost efficiency.
- Inject secrets from Secrets Manager into ECS tasks as environment variables using the `secrets` block in the task definition (managed by Terraform).
- Application containers must read secrets at runtime, not at build time.

## 5. API Gateway Setup
- Configure API Gateway as a reverse proxy.
- Route `/api/*` requests to the backend ECS service.
- Route all other requests to the frontend ECS service.
- Set up HTTPS and CORS as needed.

## 6. CI/CD Pipeline (GitHub Actions)
- Build and push Docker images for backend and frontend to ECR.
- Run tests and static analysis.
- Apply Terraform to update infrastructure.
- Deploy new ECS task definitions and services.
- Run post-deployment tests and send notifications if needed.
- AWS credentials for deploy are stored in GitHub Secrets, never in code or env files.
- No application credentials are ever exposed in the pipeline; ECS tasks fetch secrets at runtime from Secrets Manager.

## 7. Service Documentation
- For each AWS service/component, create a dedicated README.md file.
- Each README must explain:
  - What the service is
  - Why it is used
  - What problems it solves
  - Alternative options and rationale
  - Best practices and caveats
- README files must document all required environment variables and how to set up different environments.
- A `.env.example` file must be provided as a template for all required environment variables.

## 8. Monitoring & Logging
- Set up CloudWatch log groups for ECS services and API Gateway.
- Configure basic CloudWatch alarms for error rates, resource usage, and availability.

---

**Note:**
- All code, documentation, and communication must be in English (see `cursor.rules`).
- Each step should be tracked and documented before moving to the next.
- Update documentation with every relevant change.
- No credentials or sensitive values are ever hardcoded or committed to the repository. 