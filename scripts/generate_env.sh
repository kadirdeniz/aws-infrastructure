#!/bin/bash

# Generate .env file from AWS Secrets Manager
# This script extracts secrets from AWS Secrets Manager and creates a .env file

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."
ENV_FILE="${PROJECT_ROOT}/.env"

# Default values
ENVIRONMENT="dev"
PROJECT="aws-infrastructure"
SECRET_NAME=""
AWS_REGION="eu-central-1"
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

Generate .env file from AWS Secrets Manager

OPTIONS:
    -e, --environment ENV    Environment (dev/prod) [default: dev]
    -p, --project NAME       Project name [default: aws-infrastructure]
    -s, --secret-name NAME   Secret name (overrides auto-generated name)
    -r, --region REGION      AWS region [default: eu-central-1]
    -f, --force              Force overwrite existing .env file
    -h, --help               Show this help message

EXAMPLES:
    $0                          # Generate .env for dev environment
    $0 -e prod                  # Generate .env for prod environment
    $0 -e dev -f                # Force overwrite existing .env file
    $0 -s my-custom-secret      # Use custom secret name

ENVIRONMENT VARIABLES:
    AWS_PROFILE              AWS profile to use
    AWS_REGION               AWS region (overrides -r option)

EOF
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        print_error "jq is not installed. Please install jq first."
        print_status "macOS: brew install jq"
        print_status "Ubuntu/Debian: sudo apt-get install jq"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to determine secret name
get_secret_name() {
    if [ -n "$SECRET_NAME" ]; then
        echo "$SECRET_NAME"
    else
        echo "${PROJECT}-${ENVIRONMENT}-credentials"
    fi
}

# Function to check if secret exists
check_secret_exists() {
    local secret_name="$1"
    
    if aws secretsmanager describe-secret --secret-id "$secret_name" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to get secret value
get_secret_value() {
    local secret_name="$1"
    
    aws secretsmanager get-secret-value \
        --secret-id "$secret_name" \
        --region "$AWS_REGION" \
        --query 'SecretString' \
        --output text
}

# Function to convert JSON to .env format
json_to_env() {
    local json_data="$1"
    
    echo "$json_data" | jq -r 'to_entries | map("\(.key)=\(.value|tostring)") | .[]'
}

# Function to create .env file
create_env_file() {
    local secret_name="$1"
    local env_content="$2"
    
    # Check if .env file already exists
    if [ -f "$ENV_FILE" ] && [ "$FORCE" = false ]; then
        print_warning ".env file already exists: $ENV_FILE"
        read -p "Do you want to overwrite it? (y/N): " -r
        echo
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Operation cancelled."
            exit 0
        fi
    fi
    
    # Create .env file
    echo "$env_content" > "$ENV_FILE"
    
    print_success ".env file created: $ENV_FILE"
}

# Function to validate .env file
validate_env_file() {
    local env_file="$1"
    
    if [ ! -f "$env_file" ]; then
        print_error ".env file not found: $env_file"
        return 1
    fi
    
    # Check if file has content
    if [ ! -s "$env_file" ]; then
        print_error ".env file is empty"
        return 1
    fi
    
    # Check for required variables
    local required_vars=("db_host" "db_name" "db_username" "db_password")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" "$env_file"; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        print_warning "Missing variables in .env file: ${missing_vars[*]}"
    fi
    
    print_success ".env file validation passed"
}

# Function to show .env file preview
show_env_preview() {
    local env_file="$1"
    
    print_status "Preview of .env file:"
    echo ""
    echo "=== .env file content ==="
    cat "$env_file" | head -20
    echo "=== End of preview ==="
    echo ""
}

# Function to handle errors
handle_error() {
    print_error "Failed to generate .env file!"
    print_status "Check the logs above for details."
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
        -p|--project)
            PROJECT="$2"
            shift 2
            ;;
        -s|--secret-name)
            SECRET_NAME="$2"
            shift 2
            ;;
        -r|--region)
            AWS_REGION="$2"
            shift 2
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

# Main process
main() {
    echo ""
    print_status "Starting .env file generation from AWS Secrets Manager"
    print_status "Environment: $ENVIRONMENT"
    print_status "Project: $PROJECT"
    print_status "Region: $AWS_REGION"
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Determine secret name
    local secret_name
    secret_name=$(get_secret_name)
    print_status "Using secret: $secret_name"
    
    # Check if secret exists
    if ! check_secret_exists "$secret_name"; then
        print_error "Secret '$secret_name' not found in AWS Secrets Manager"
        print_status "Make sure the infrastructure is deployed first using:"
        print_status "  ./scripts/deploy.sh -e $ENVIRONMENT"
        exit 1
    fi
    
    # Get secret value
    print_status "Retrieving secret value..."
    local secret_value
    secret_value=$(get_secret_value "$secret_name")
    
    if [ -z "$secret_value" ]; then
        print_error "Failed to retrieve secret value"
        exit 1
    fi
    
    # Convert JSON to .env format
    print_status "Converting secret to .env format..."
    local env_content
    env_content=$(json_to_env "$secret_value")
    
    if [ -z "$env_content" ]; then
        print_error "Failed to convert secret to .env format"
        exit 1
    fi
    
    # Create .env file
    create_env_file "$secret_name" "$env_content"
    
    # Validate .env file
    validate_env_file "$ENV_FILE"
    
    # Show preview
    show_env_preview "$ENV_FILE"
    
    echo ""
    print_success ".env file generated successfully!"
    print_status "File location: $ENV_FILE"
    print_status ""
    print_status "Next steps:"
    print_status "1. Review the .env file content"
    print_status "2. Use the variables in your application"
    print_status "3. Add .env to your .gitignore if not already done"
    print_status "4. Restart your application to use the new environment variables"
}

# Run main function
main "$@" 