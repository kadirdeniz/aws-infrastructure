#!/bin/bash

# Generic Terraform Module Testing Script
# Usage: ./test_module.sh <module_name>
# Example: ./test_module.sh rds

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if module name is provided
if [ $# -eq 0 ]; then
    print_error "Module name is required!"
    echo "Usage: $0 <module_name>"
    echo "Available modules: vpc, iam, rds"
    exit 1
fi

MODULE_NAME=$1
TEST_DIR="${MODULE_NAME}_test"

# Validate module name
if [ ! -d "$TEST_DIR" ]; then
    print_error "Test directory '$TEST_DIR' not found!"
    echo "Available test directories:"
    ls -d *_test 2>/dev/null || echo "No test directories found"
    exit 1
fi

print_status "Starting test for module: $MODULE_NAME"
print_status "Test directory: $TEST_DIR"

# Copy provider.tf to test directory
if [ -f "provider.tf" ]; then
    cp provider.tf "$TEST_DIR/"
    print_status "Copied provider.tf to $TEST_DIR/"
fi

cd "$TEST_DIR"

# Initialize Terraform
print_status "Initializing Terraform for $MODULE_NAME..."
terraform init

# Find and use tfvars file if it exists
tfvars_file=$(find . -name "*.tfvars" | head -1)
if [ -n "$tfvars_file" ]; then
    print_status "Using tfvars file: $tfvars_file"
    terraform plan -var-file="$tfvars_file" -out=tfplan
else
    print_status "No tfvars file found, using default values"
    terraform plan -out=tfplan
fi

# Apply the configuration
print_status "Applying $MODULE_NAME configuration..."
terraform apply tfplan

# Wait a moment for resources to be fully created
print_status "Waiting for $MODULE_NAME resources to stabilize..."
sleep 10

# Optional: Add validation checks here
print_status "Validating $MODULE_NAME resources..."
# Add specific validation logic for each module if needed

# Destroy the test resources
print_status "Destroying $MODULE_NAME test resources..."
terraform destroy -auto-approve

# Clean up
rm -f tfplan
rm -rf .terraform*
rm -f provider.tf

cd ..

print_success "$MODULE_NAME test completed successfully!"
echo "----------------------------------------" 