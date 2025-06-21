#!/bin/bash

# CloudWatch Module Test Script
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="${SCRIPT_DIR}/cloudwatch_test"

echo "🚀 Starting CloudWatch module test..."
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
terraform plan -var-file="cloudwatch.tfvars" -out=tfplan

echo "🔧 Applying Terraform configuration..."
terraform apply -auto-approve tfplan

echo "📊 Getting outputs..."
echo "Dashboard URL:"
terraform output dashboard_url

echo "🧹 Destroying test resources..."
terraform destroy -auto-approve -var-file="cloudwatch.tfvars"

echo "✅ CloudWatch module test completed successfully!" 