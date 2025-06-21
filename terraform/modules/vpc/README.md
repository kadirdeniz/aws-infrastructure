# VPC Module

## What is this?
This module provisions an Amazon Virtual Private Cloud (VPC) with public and private subnets, route tables, and basic networking resources for secure, isolated infrastructure.

## Why is it used?
- Provides network isolation and segmentation for all AWS resources.
- Enables secure communication between services (e.g., RDS, ECS) within private subnets.
- Allows public access only where explicitly required (e.g., load balancers, NAT gateways).

## Problems it solves
- Prevents direct public access to sensitive resources (e.g., databases).
- Simplifies network management and security group configuration.
- Supports multi-AZ high availability and future scaling.

## Alternatives considered
- Default VPC (not secure or flexible enough for production).
- Manually managing all networking resources in each service module (not DRY, error-prone).

## Best Practices
- Use private subnets for all compute and database resources.
- Use public subnets only for resources that must be internet-facing.
- Tag all resources for environment and ownership.
- Enable flow logs for auditing and troubleshooting.

---

See the root README and `docs/workflow.md` for usage and integration details. 