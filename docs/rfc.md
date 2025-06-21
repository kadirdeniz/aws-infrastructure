# RFC: Minimal Cost Serverless AWS Infrastructure with Terraform

## Purpose
This document defines the requirements and architecture for building a minimal-cost, open-source, serverless AWS infrastructure managed with Terraform, supporting both development (dev) and production (prod) environments.

## Scope
- **Backend:** Docker container running on ECS Fargate.
- **Frontend:** Dockerized frontend container served via ECS Fargate (framework-agnostic).
- **Database:** Amazon RDS PostgreSQL (free tier where possible).
- **Secrets:** AWS Secrets Manager (single secret, only credentials).
- **API Gateway:** Reverse proxy and routing.
- **CI/CD:** Automated build, test, and deploy pipeline (GitHub Actions).
- **Cost:** Minimized by using free tier and minimal resources.
- **Environments:** Both dev and prod environments will be provisioned and managed.

---

## AWS Services and Details

### 1. Amazon ECS Fargate
- **Purpose:** Run backend and frontend containers serverlessly.
- **Resources:** Minimal (0.25 vCPU, 0.5 GB RAM per service).
- **Free tier:** 50 hours/month per account.
- **Note:** Separate ECS services for backend and frontend in both dev and prod.

### 2. Amazon RDS (PostgreSQL)
- **Purpose:** Relational database.
- **Resources:** db.t3.micro (1 vCPU, 1GB RAM) — 750 hours/month free tier.
- **Note:** Separate databases for dev and prod.

### 3. AWS Secrets Manager
- **Purpose:** Store only credentials (RDS connection info, optionally S3 keys, etc.).
- **Design:**
  - A single secret per environment (e.g., `app-dev-credentials`, `app-prod-credentials`).
  - Secret is a JSON object (see below).
  - Only ECS tasks for the relevant environment can access the secret (IAM policy).
- **Example Secret JSON:**
```json
{
  "host": "<rds-endpoint>",
  "port": 5432,
  "dbname": "appdb",
  "username": "appuser",
  "password": "supersecret"
}
```

### 4. Amazon API Gateway
- **Purpose:** HTTP endpoint, reverse proxy, routing.
- **Routing:**
  - `/api/*` → backend ECS service
  - all others → frontend ECS service
- **HTTPS enforced, CORS and rate limiting enabled.**

### 5. IAM
- **Purpose:** Service-to-service access control.
- **Best Practice:** Principle of least privilege for all roles and policies.

### 6. VPC, Subnet, Security Group
- **Purpose:** Network isolation and security.
- **Design:** RDS and ECS run in private subnets, only API Gateway is public.

### 7. CloudWatch
- **Purpose:** Logging, monitoring, alarms.

### 8. ECR
- **Purpose:** Store Docker images for backend and frontend.

---

## CI/CD Pipeline (GitHub Actions)
- **Source control:** GitHub
- **Pipeline:** GitHub Actions
- **Steps:**
  1. On code push, pipeline is triggered.
  2. Run tests and static analysis.
  3. Build Docker images and push to ECR.
  4. Apply Terraform to update infrastructure (ECS, RDS, API Gateway, etc.).
  5. Deploy new ECS task definitions and services.
  6. Run post-deployment tests and send notifications if needed.
- **Secret Management:**
  - AWS credentials for deploy are stored in GitHub Secrets.
  - Application credentials are never exposed in the pipeline; ECS tasks fetch secrets at runtime from Secrets Manager.
  - Terraform configures ECS task definitions to inject secrets as environment variables using the `secrets` block.

---

## Security and Best Practices
- **Secrets Manager is mandatory for all credentials.**
- **No credentials are hardcoded or stored in plaintext.**
- **RDS and ECS run in private subnets.**
- **API Gateway enforces HTTPS.**
- **IAM policies are least privilege.**
- **CloudWatch logs and alarms are enabled.**
- **Terraform state is stored in S3 with DynamoDB lock.**
- **CloudTrail is enabled for auditing.**
- **Secret rotation can be enabled for RDS credentials if required.**

---

## Cost Analysis (Monthly Estimate)
| Service              | Free Tier         | Estimated Cost (if exceeded) |
|----------------------|------------------|------------------------------|
| ECS Fargate          | 50 hours/month   | $10-20 (low traffic)         |
| RDS PostgreSQL       | 750 hours/month  | $15                          |
| Secrets Manager      | 30 days/secret   | $0.40/secret                 |
| API Gateway          | 1M calls/month   | $3.50/million calls          |
| S3                   | 5GB/month        | $0.023/GB                    |
| ECR                  | 500MB/month      | $0.10/GB                     |
| CloudWatch           | 5GB/month        | $0.50/GB                     |

**Note:** If only free tier is used, monthly cost is close to $0. If exceeded, total cost for a small, low-traffic app is ~$20-30.

---

## Secrets Manager Usage
- Only credentials (RDS, optionally S3, etc.) are stored.
- One secret per environment (dev, prod), not per service.
- Secret is a JSON object.
- Access is restricted to ECS tasks in the relevant environment.
- No other sensitive data is stored in Secrets Manager.

---

## Environments
- Both dev and prod environments are provisioned and managed.
- Each environment has its own VPC, RDS, ECS services, and Secrets Manager secret.
- Resource names are suffixed/prefixed with the environment (e.g., `app-dev-backend`, `app-prod-backend`).
- CI/CD pipeline can deploy to either environment based on branch or manual trigger.

---

## Open Questions / To Be Finalized
- Will secret rotation for RDS credentials be enabled?
- What is the retention policy for CloudWatch and CloudTrail logs?
- Is disaster recovery (backup/restore) required for secrets and state files?

---

## References
- [AWS Free Tier Pricing](https://aws.amazon.com/free/)
- [Serverless + Terraform Integration](https://www.serverless.com/blog/definitive-guide-terraform-serverless)
- [Terraform Serverless API & CI/CD Example](https://medium.com/cloud-native-daily/building-a-serverless-application-using-terraform-d455c03ac5b4)
- [AWS Secrets Manager Documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html)
- [AWS Prescriptive Guidance: Manage credentials using AWS Secrets Manager](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/manage-credentials-using-aws-secrets-manager.html) 