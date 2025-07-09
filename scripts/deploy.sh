#!/bin/bash

# Slack Topic Updater Lambda Deployment Script
# This script helps deploy the Lambda function using SAM CLI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if SAM CLI is installed
check_sam_cli() {
    if ! command -v sam &> /dev/null; then
        print_error "SAM CLI is not installed. Please install it first:"
        echo "  pip install aws-sam-cli"
        echo "  or visit: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
        exit 1
    fi
    print_status "SAM CLI is installed"
}

# Check if AWS CLI is configured
check_aws_cli() {
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured. Please run 'aws configure' first."
        exit 1
    fi
    print_status "AWS CLI is configured"
}

# Build the application
build() {
    print_status "Building the application..."
    sam build
    print_status "Build completed successfully"
}

# Deploy the application
deploy() {
    local environment=${1:-default}
    local slack_token=${2}
    local slack_channel=${3}

    if [ -z "$slack_token" ] || [ -z "$slack_channel" ]; then
        print_error "Please provide Slack token and channel ID:"
        echo "  ./deploy.sh deploy <environment> <slack_token> <slack_channel_id>"
        echo "  Example: ./deploy.sh deploy production xoxb-your-token C1234567890"
        exit 1
    fi

    print_status "Deploying to $environment environment..."

    # Build first
    build

    # Deploy with parameters
    sam deploy \
        --capabilities CAPABILITY_NAMED_IAM \
        --config-env $environment \
        --parameter-overrides \
        SlackAuthToken="$slack_token" \
        SlackChannelId="$slack_channel" \
        --no-fail-on-empty-changeset \
        --no-confirm-changeset

    print_status "Deployment completed successfully"
}

# Deploy to development
deploy_development() {
    local slack_token=${1}
    local slack_channel=${2}
    deploy "development" "$slack_token" "$slack_channel"
}

# Deploy to production
deploy_production() {
    local slack_token=${1}
    local slack_channel=${2}
    deploy "production" "$slack_token" "$slack_channel"
}

# remove the stack
remove() {
    local environment=${1:-default}
    print_warning "This will remove the entire stack. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Deleting stack..."
        sam delete --config-env $environment
        print_status "Stack removed successfully"
    else
        print_status "Deletion cancelled"
    fi
}

# Show stack outputs
outputs() {
    local environment=${1:-default}
    print_status "Getting stack outputs..."
    sam list stack-outputs --config-env $environment
}

# Test the function locally
test_local() {
    print_status "Testing function locally..."
    sam local invoke SlackTopicUpdaterFunction \
        --env-vars env.json \
        --event events/test-event.json
}

# Show logs
logs() {
    local environment=${1:-default}
    print_status "Showing function logs..."
    sam logs --config-env $environment --tail
}

# Show help
show_help() {
    echo "Slack Topic Updater Lambda Deployment Script"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  build                    Build the application"
    echo "  deploy <env> <token> <channel>  Deploy to specified environment"
    echo "  deploy-development <token> <channel>    Deploy to development environment"
    echo "  deploy-production <token> <channel>   Deploy to production environment"
    echo "  remove [env]             remove the stack"
    echo "  outputs [env]            Show stack outputs"
    echo "  test-local               Test the function locally"
    echo "  logs [env]               Show function logs"
    echo "  help                     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 deploy-development xoxb-your-token C1234567890"
    echo "  $0 deploy-production xoxb-your-token C1234567890"
    echo "  $0 remove production"
    echo "  $0 outputs production"
}

# Main script logic
main() {
    check_sam_cli
    check_aws_cli

    case "${1:-help}" in
        build)
            build
            ;;
        deploy)
            deploy "$2" "$3" "$4"
            ;;
        deploy-development)
            deploy_development "$2" "$3"
            ;;
        deploy-production)
            deploy_production "$2" "$3"
            ;;
        remove)
            remove "$2"
            ;;
        outputs)
            outputs "$2"
            ;;
        test-local)
            test_local
            ;;
        logs)
            logs "$2"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
