#!/bin/bash

# API Gateway Module Test Script
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="${SCRIPT_DIR}/apigateway_test"

echo "🚀 Starting API Gateway module test..."
echo "Test directory: ${TEST_DIR}"

if [ ! -d "${TEST_DIR}" ]; then
    echo "❌ Test directory not found: ${TEST_DIR}"
    exit 1
fi

cd "${TEST_DIR}"

echo "📦 Initializing Terraform..."
terraform init

echo "✅ Validating Terraform configuration..."
terraform validate

echo "📋 Creating Terraform plan..."
terraform plan -var-file="apigateway.tfvars" -out=tfplan

echo "🔍 Plan created successfully. Review the plan above."
echo ""
echo "To apply the changes, run:"
echo "  terraform apply tfplan"
echo ""
echo "To destroy the resources, run:"
echo "  terraform destroy -var-file=apigateway.tfvars"
echo ""
echo "To get the API endpoint after apply, run:"
echo "  terraform output api_endpoint"
echo ""
echo "✅ API Gateway module test completed successfully!" 