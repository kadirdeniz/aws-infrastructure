#!/bin/bash

# ECS Module Test Script
# This script tests the ECS module in isolation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="${SCRIPT_DIR}/ecs_test"

echo "🚀 Starting ECS module test..."
echo "Test directory: ${TEST_DIR}"

# Check if test directory exists
if [ ! -d "${TEST_DIR}" ]; then
    echo "❌ Test directory not found: ${TEST_DIR}"
    exit 1
fi

# Change to test directory
cd "${TEST_DIR}"

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Plan the deployment
echo "📋 Creating Terraform plan..."
terraform plan -var-file="ecs.tfvars" -out=tfplan

echo "🔍 Plan created successfully. Review the plan above."
echo ""
echo "To apply the changes, run:"
echo "  terraform apply tfplan"
echo ""
echo "To destroy the resources, run:"
echo "  terraform destroy -var-file=ecs.tfvars"
echo ""
echo "✅ ECS module test completed successfully!" 