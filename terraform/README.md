# Terraform Infrastructure

This directory contains the infrastructure-as-code (IaC) configuration for the project, managed with Terraform. All AWS resources are provisioned and managed from here, following best practices for modularity, security, and cost efficiency.

## Structure
- `main.tf`, `variables.tf`, `outputs.tf`, `provider.tf`: Root configuration files.
- `terraform.tfvars.example`: Example variable values (no secrets).
- `modules/`: Contains service modules (e.g., rds, vpc, ecs), each with its own folder and documentation. Modules are added only when implemented.

## Usage
- All sensitive data is managed via environment variables or AWS Secrets Manager.
- See `../docs/workflow.md` and `../docs/folder-structure.md` for process and best practices.

---

**Do not commit real secrets or credentials.** 