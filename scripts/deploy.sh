#!/bin/bash

# AWS Infrastructure Deployment Script
# This script deploys the complete AWS infrastructure using Terraform

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

Deploy AWS infrastructure using Terraform

OPTIONS:
    -e, --environment ENV    Environment to deploy (dev/prod) [default: dev]
    -a, --auto-approve      Auto-approve Terraform changes
    -p, --plan-only         Only create plan, don't apply
    -n, --no-backup         Don't backup Terraform state
    -h, --help              Show this help message

EXAMPLES:
    $0                          # Deploy dev environment with prompts
    $0 -e prod -a              # Deploy prod environment with auto-approve
    $0 -e dev -p               # Only create plan for dev environment
    $0 -e prod -a -n           # Deploy prod without state backup

ENVIRONMENT VARIABLES:
    TF_VAR_db_username        Database username (required)
    TF_VAR_db_password        Database password (required)
    AWS_PROFILE              AWS profile to use
    AWS_REGION               AWS region (overrides terraform.tfvars)

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
    
    # Check Terraform version
    TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
    print_status "Terraform version: $TF_VERSION"
    
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
    
    # Check required environment variables
    if [ -z "$TF_VAR_db_username" ]; then
        print_error "TF_VAR_db_username environment variable is required."
        print_status "Example: export TF_VAR_db_username=myuser"
        exit 1
    fi
    
    if [ -z "$TF_VAR_db_password" ]; then
        print_error "TF_VAR_db_password environment variable is required."
        print_status "Example: export TF_VAR_db_password=mypassword"
        exit 1
    fi
    
    # Check if terraform.tfvars exists
    if [ ! -f "${TERRAFORM_DIR}/terraform.tfvars" ]; then
        print_warning "terraform.tfvars not found. Creating from example..."
        cp "${TERRAFORM_DIR}/terraform.tfvars.example" "${TERRAFORM_DIR}/terraform.tfvars"
        print_status "Please edit ${TERRAFORM_DIR}/terraform.tfvars with your configuration."
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

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    cd "$TERRAFORM_DIR"
    
    # Initialize Terraform
    terraform init
    
    print_success "Terraform initialized"
}

# Function to validate Terraform configuration
validate_terraform() {
    print_status "Validating Terraform configuration..."
    cd "$TERRAFORM_DIR"
    
    if terraform validate; then
        print_success "Terraform configuration is valid"
    else
        print_error "Terraform configuration validation failed"
        exit 1
    fi
}

# Function to create Terraform plan
create_plan() {
    print_status "Creating Terraform plan..."
    cd "$TERRAFORM_DIR"
    
    PLAN_FILE="tfplan"
    
    # Create plan
    terraform plan \
        -var="environment=${ENVIRONMENT}" \
        -out="$PLAN_FILE"
    
    print_success "Plan created: $PLAN_FILE"
}

# Function to apply Terraform configuration
apply_terraform() {
    if [ "$PLAN_ONLY" = true ]; then
        print_status "Plan-only mode. Skipping apply."
        return
    fi
    
    print_status "Applying Terraform configuration..."
    cd "$TERRAFORM_DIR"
    
    if [ "$AUTO_APPROVE" = true ]; then
        terraform apply -auto-approve tfplan
    else
        terraform apply tfplan
    fi
    
    print_success "Terraform configuration applied successfully"
}

# Function to show outputs
show_outputs() {
    if [ "$PLAN_ONLY" = true ]; then
        return
    fi
    
    print_status "Infrastructure outputs:"
    cd "$TERRAFORM_DIR"
    
    echo ""
    terraform output
    echo ""
    
    # Show important URLs
    API_URL=$(terraform output -raw api_gateway_url 2>/dev/null || echo "Not available")
    DASHBOARD_URL=$(terraform output -raw cloudwatch_dashboard_url 2>/dev/null || echo "Not available")
    
    if [ "$API_URL" != "Not available" ]; then
        print_success "API Gateway URL: $API_URL"
    fi
    
    if [ "$DASHBOARD_URL" != "Not available" ]; then
        print_success "CloudWatch Dashboard: $DASHBOARD_URL"
    fi
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up..."
    cd "$TERRAFORM_DIR"
    
    # Remove plan file
    if [ -f "tfplan" ]; then
        rm tfplan
    fi
    
    print_success "Cleanup completed"
}

# Function to handle errors
handle_error() {
    print_error "Deployment failed!"
    print_status "Check the logs above for details."
    print_status "You can run 'terraform plan' in ${TERRAFORM_DIR} to see what went wrong."
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

# Main deployment process
main() {
    echo ""
    print_status "Starting AWS Infrastructure Deployment"
    print_status "Environment: $ENVIRONMENT"
    print_status "Auto-approve: $AUTO_APPROVE"
    print_status "Plan-only: $PLAN_ONLY"
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Create backup directories
    create_backup_dirs
    
    # Backup state if needed
    backup_state
    
    # Initialize Terraform
    init_terraform
    
    # Validate configuration
    validate_terraform
    
    # Create plan
    create_plan
    
    # Apply configuration
    apply_terraform
    
    # Show outputs
    show_outputs
    
    # Cleanup
    cleanup
    
    echo ""
    print_success "Deployment completed successfully!"
    
    if [ "$PLAN_ONLY" = false ]; then
        echo ""
        print_status "Next steps:"
        print_status "1. Push your Docker images to ECR repositories"
        print_status "2. Update ECS services with new task definitions"
        print_status "3. Test your application endpoints"
        print_status "4. Monitor logs in CloudWatch"
    fi
}

# Run main function
main "$@" 