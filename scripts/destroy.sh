#!/bin/bash

# AWS Infrastructure Destroy Script
# This script safely destroys the AWS infrastructure using Terraform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../terraform"
BACKUP_DIR="${SCRIPT_DIR}/../backups"
LOG_DIR="${SCRIPT_DIR}/../logs"

# Default values
ENVIRONMENT="dev"
AUTO_APPROVE=false
PLAN_ONLY=false
BACKUP_STATE=true
FORCE=false

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

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Destroy AWS infrastructure using Terraform

⚠️  WARNING: This will permanently delete all AWS resources!
⚠️  Make sure you have backups of any important data!

OPTIONS:
    -e, --environment ENV    Environment to destroy (dev/prod) [default: dev]
    -a, --auto-approve      Auto-approve Terraform destroy
    -p, --plan-only         Only create destroy plan, don't execute
    -n, --no-backup         Don't backup Terraform state
    -f, --force             Force destroy without confirmation prompts
    -h, --help              Show this help message

EXAMPLES:
    $0                          # Destroy dev environment with prompts
    $0 -e prod -a              # Destroy prod environment with auto-approve
    $0 -e dev -p               # Only create destroy plan for dev environment
    $0 -e prod -a -n           # Destroy prod without state backup
    $0 -e dev -f               # Force destroy dev environment

ENVIRONMENT VARIABLES:
    AWS_PROFILE              AWS profile to use
    AWS_REGION               AWS region

EOF
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    # Check if terraform.tfstate exists
    if [ ! -f "${TERRAFORM_DIR}/terraform.tfstate" ]; then
        print_error "No Terraform state found. Nothing to destroy."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to create backup directories
create_backup_dirs() {
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$LOG_DIR"
}

# Function to backup Terraform state
backup_state() {
    if [ "$BACKUP_STATE" = true ] && [ -f "${TERRAFORM_DIR}/terraform.tfstate" ]; then
        print_status "Backing up Terraform state..."
        BACKUP_FILE="${BACKUP_DIR}/terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)"
        cp "${TERRAFORM_DIR}/terraform.tfstate" "$BACKUP_FILE"
        print_success "State backed up to: $BACKUP_FILE"
    fi
}

# Function to show current resources
show_current_resources() {
    print_status "Current infrastructure resources:"
    cd "$TERRAFORM_DIR"
    
    echo ""
    terraform state list
    echo ""
    
    # Show important resources that will be destroyed
    print_warning "The following resources will be destroyed:"
    
    # Check for RDS instances
    if terraform state list | grep -q "aws_db_instance"; then
        print_warning "- RDS Database instances"
    fi
    
    # Check for ECS services
    if terraform state list | grep -q "aws_ecs_service"; then
        print_warning "- ECS Services"
    fi
    
    # Check for ECR repositories
    if terraform state list | grep -q "aws_ecr_repository"; then
        print_warning "- ECR Repositories"
    fi
    
    # Check for API Gateway
    if terraform state list | grep -q "aws_api_gateway"; then
        print_warning "- API Gateway"
    fi
    
    # Check for VPC
    if terraform state list | grep -q "aws_vpc"; then
        print_warning "- VPC and Network resources"
    fi
    
    echo ""
}

# Function to confirm destruction
confirm_destruction() {
    if [ "$FORCE" = true ]; then
        print_warning "Force mode enabled. Skipping confirmation."
        return
    fi
    
    if [ "$AUTO_APPROVE" = true ]; then
        print_warning "Auto-approve mode enabled. Skipping confirmation."
        return
    fi
    
    echo ""
    print_error "⚠️  WARNING: This will permanently delete all AWS resources! ⚠️"
    echo ""
    print_warning "This action cannot be undone. All data will be lost."
    echo ""
    
    read -p "Are you sure you want to destroy the ${ENVIRONMENT} environment? (yes/no): " -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_status "Destroy cancelled by user."
        exit 0
    fi
    
    echo ""
    print_warning "Final confirmation required..."
    read -p "Type 'DESTROY' to confirm: " -r
    echo
    
    if [[ ! $REPLY =~ ^DESTROY$ ]]; then
        print_status "Destroy cancelled by user."
        exit 0
    fi
}

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    cd "$TERRAFORM_DIR"
    
    # Initialize Terraform
    terraform init
    
    print_success "Terraform initialized"
}

# Function to create destroy plan
create_destroy_plan() {
    print_status "Creating destroy plan..."
    cd "$TERRAFORM_DIR"
    
    PLAN_FILE="tfplan"
    
    # Create destroy plan
    terraform plan \
        -var="environment=${ENVIRONMENT}" \
        -destroy \
        -out="$PLAN_FILE"
    
    print_success "Destroy plan created: $PLAN_FILE"
}

# Function to execute destroy
execute_destroy() {
    if [ "$PLAN_ONLY" = true ]; then
        print_status "Plan-only mode. Skipping destroy."
        return
    fi
    
    print_status "Executing Terraform destroy..."
    cd "$TERRAFORM_DIR"
    
    if [ "$AUTO_APPROVE" = true ]; then
        terraform apply -auto-approve tfplan
    else
        terraform apply tfplan
    fi
    
    print_success "Infrastructure destroyed successfully"
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up..."
    cd "$TERRAFORM_DIR"
    
    # Remove plan file
    if [ -f "tfplan" ]; then
        rm tfplan
    fi
    
    # Remove .terraform directory if it exists
    if [ -d ".terraform" ]; then
        rm -rf .terraform
    fi
    
    print_success "Cleanup completed"
}

# Function to handle errors
handle_error() {
    print_error "Destroy failed!"
    print_status "Check the logs above for details."
    print_status "You can run 'terraform plan -destroy' in ${TERRAFORM_DIR} to see what went wrong."
    exit 1
}

# Set error handler
trap handle_error ERR

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -a|--auto-approve)
            AUTO_APPROVE=true
            shift
            ;;
        -p|--plan-only)
            PLAN_ONLY=true
            shift
            ;;
        -n|--no-backup)
            BACKUP_STATE=false
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main destroy process
main() {
    echo ""
    print_status "Starting AWS Infrastructure Destruction"
    print_status "Environment: $ENVIRONMENT"
    print_status "Auto-approve: $AUTO_APPROVE"
    print_status "Plan-only: $PLAN_ONLY"
    print_status "Force: $FORCE"
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Create backup directories
    create_backup_dirs
    
    # Backup state if needed
    backup_state
    
    # Show current resources
    show_current_resources
    
    # Confirm destruction
    confirm_destruction
    
    # Initialize Terraform
    init_terraform
    
    # Create destroy plan
    create_destroy_plan
    
    # Execute destroy
    execute_destroy
    
    # Cleanup
    cleanup
    
    echo ""
    print_success "Infrastructure destruction completed successfully!"
    
    if [ "$PLAN_ONLY" = false ]; then
        echo ""
        print_status "All AWS resources have been destroyed."
        print_status "Remember to:"
        print_status "1. Update your DNS records if you had custom domains"
        print_status "2. Remove any manual AWS resources not managed by Terraform"
        print_status "3. Clean up any local backups if no longer needed"
    fi
}

# Run main function
main "$@" 