# Terraform Folder Structure Documentation

This document describes the folder and file structure used for the Terraform configuration in this project. It follows best practices for maintainability, clarity, and open source collaboration.

## Modular, Service-Based Folder Structure

Each infrastructure service (e.g., VPC, RDS, ECS, IAM) is implemented as a dedicated module under the `modules/` directory. **Module folders and their files are created only when that service is being implemented.** Do not create all service folders at once. For each service:
- Create a subfolder under `modules/` (e.g., `modules/rds/`).
- Implement the service's Terraform code in `main.tf`, `variables.tf`, and `outputs.tf`.
- Add a `README.md` documenting the service, its purpose, usage, and best practices.
- Complete and document the service before moving to the next.

## Example Folder Structure
```
terraform/
  ├── main.tf
  ├── variables.tf
  ├── outputs.tf
  ├── provider.tf
  ├── terraform.tfvars.example
  ├── README.md
  └── modules/
      ├── rds/
      │   ├── main.tf
      │   ├── variables.tf
      │   ├── outputs.tf
      │   └── README.md
      └── ... (other service modules added as needed)
```

## Process
1. When a new service is needed, create its module folder under `modules/`.
2. Implement the service's Terraform code and documentation in that folder.
3. Only after the service is complete and documented, move to the next service.
4. Do not create empty or placeholder module folders/files for services not yet being implemented.

## Best Practices
- Never commit real secrets or credentials. Use environment variables or secret managers for sensitive data.
- Keep all configuration and documentation in English.
- Update this documentation with any environment-specific details or instructions.
- Use version control for all Terraform files and review changes to lock files and state management.

## Further Reading
- [Terraform Files and Folder Structure: Organizing Infrastructure-as-Code (env0)](https://www.env0.com/blog/terraform-files-and-folder-structure-organizing-infrastructure-as-code)
- [Terraform Files – How to Structure a Terraform Project (Spacelift)](https://spacelift.io/blog/terraform-files) 