#!/bin/bash

# Secrets Manager Module Test Script
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="${SCRIPT_DIR}/secretsmanager_test"

echo "🚀 Starting Secrets Manager module test..."
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
terraform plan -var-file="secretsmanager.tfvars" -out=tfplan

echo "🔧 Applying Terraform configuration..."
terraform apply -auto-approve tfplan

echo "📊 Getting outputs..."
echo "Secret ARN:"
terraform output secret_arn

echo "🧹 Destroying test resources..."
terraform destroy -auto-approve -var-file="secretsmanager.tfvars"

echo "✅ Secrets Manager module test completed successfully!" 