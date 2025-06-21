#!/bin/bash

# Terraform Integration Testing Script
# This script builds the entire infrastructure system and then destroys it
# This is an integration test that validates all modules work together

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Arrays to track results
SUCCESSFUL_MODULES=()
FAILED_MODULES=()

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

# Function to run a single module apply with error handling
run_module_apply() {
    local test_dir=$1
    local module_name=$2
    
    print_status "Testing $module_name module..."
    
    if [ ! -d "$test_dir" ]; then
        print_error "Test directory $test_dir not found!"
        FAILED_MODULES+=("$module_name (directory not found)")
        return 1
    fi
    
    cd "$test_dir"
    
    # Initialize Terraform
    print_status "Initializing $module_name..."
    if ! terraform init -input=false; then
        print_error "Failed to initialize $module_name"
        FAILED_MODULES+=("$module_name (init failed)")
        cd ..
        return 1
    fi
    
    # Plan the deployment
    print_status "Planning $module_name deployment..."
    tfvars_file=$(find . -name "*.tfvars" | head -1)
    if [ -n "$tfvars_file" ]; then
        if ! terraform plan -var-file="$tfvars_file" -out=tfplan; then
            print_error "Failed to plan $module_name"
            FAILED_MODULES+=("$module_name (plan failed)")
            cd ..
            return 1
        fi
    else
        if ! terraform plan -out=tfplan; then
            print_error "Failed to plan $module_name"
            FAILED_MODULES+=("$module_name (plan failed)")
            cd ..
            return 1
        fi
    fi
    
    # Apply the deployment
    print_status "Applying $module_name deployment..."
    if ! terraform apply -auto-approve tfplan; then
        print_error "Failed to apply $module_name"
        FAILED_MODULES+=("$module_name (apply failed)")
        cd ..
        return 1
    fi
    
    print_success "$module_name module deployed successfully!"
    SUCCESSFUL_MODULES+=("$module_name")
    cd ..
}

# Function to run a single module destroy with error handling
run_module_destroy() {
    local test_dir=$1
    local module_name=$2
    
    print_status "Destroying $module_name module..."
    
    if [ ! -d "$test_dir" ]; then
        print_warning "Test directory $test_dir not found, skipping destroy"
        return 0
    fi
    
    cd "$test_dir"
    
    # Check if state exists
    if [ ! -f "terraform.tfstate" ]; then
        print_warning "No state file found for $module_name, skipping destroy"
        cd ..
        return 0
    fi
    
    # Destroy the deployment
    print_status "Destroying $module_name deployment..."
    if ! terraform destroy -auto-approve; then
        print_error "Failed to destroy $module_name"
        print_warning "Manual cleanup may be required for $module_name"
        cd ..
        return 1
    fi
    
    print_success "$module_name module destroyed successfully!"
    cd ..
}

# Function to print test summary
print_summary() {
    echo ""
    echo "=========================================="
    echo "           TEST SUMMARY"
    echo "=========================================="
    
    if [ ${#SUCCESSFUL_MODULES[@]} -gt 0 ]; then
        echo ""
        print_success "SUCCESSFUL MODULES (${#SUCCESSFUL_MODULES[@]}):"
        for module in "${SUCCESSFUL_MODULES[@]}"; do
            echo "  ✅ $module"
        done
    fi
    
    if [ ${#FAILED_MODULES[@]} -gt 0 ]; then
        echo ""
        print_error "FAILED MODULES (${#FAILED_MODULES[@]}):"
        for module in "${FAILED_MODULES[@]}"; do
            echo "  ❌ $module"
        done
    fi
    
    echo ""
    echo "=========================================="
    
    # Exit with error if any module failed
    if [ ${#FAILED_MODULES[@]} -gt 0 ]; then
        print_error "Some modules failed during testing!"
        exit 1
    else
        print_success "All modules tested successfully!"
        exit 0
    fi
}

# Main execution
echo "=========================================="
echo "    TERRAFORM INTEGRATION TESTING"
echo "=========================================="
echo ""

# Copy provider.tf to each test directory
print_status "Setting up test environment..."

# Test directories in dependency order
TEST_DIRS=("vpc_test" "iam_test" "ecr_test" "rds_test" "ecs_test" "apigateway_test" "secretsmanager_test" "cloudwatch_test")
MODULE_NAMES=("VPC" "IAM" "ECR" "RDS" "ECS" "APIGATEWAY" "SECRETSMANAGER" "CLOUDWATCH")

# Phase 1: Apply all modules
print_status "PHASE 1: Building infrastructure..."
echo ""

for i in "${!TEST_DIRS[@]}"; do
    test_dir="${TEST_DIRS[$i]}"
    module_name="${MODULE_NAMES[$i]}"
    
    if run_module_apply "$test_dir" "$module_name"; then
        print_success "$module_name module completed successfully"
    else
        print_warning "$module_name module failed, continuing with next module..."
    fi
    
    echo ""
done

# Phase 2: Destroy all modules (in reverse order)
print_status "PHASE 2: Cleaning up infrastructure..."
echo ""

# Reverse the arrays for destroy order
for ((i=${#TEST_DIRS[@]}-1; i>=0; i--)); do
    test_dir="${TEST_DIRS[$i]}"
    module_name="${MODULE_NAMES[$i]}"
    
    if run_module_destroy "$test_dir" "$module_name"; then
        print_success "$module_name cleanup completed"
    else
        print_warning "$module_name cleanup failed, continuing..."
    fi
    
    echo ""
done

# Print final summary
print_summary 