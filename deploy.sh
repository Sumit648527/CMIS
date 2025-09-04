#!/bin/bash

# CMIS Deployment Script
set -e

echo "🚀 Starting CMIS Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION="us-east-1"
STACK_NAME="cmis-stack"
KEY_PAIR_NAME="cmis-keypair"
INSTANCE_TYPE="t3.medium"

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

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install it first."
    exit 1
fi

# Check AWS credentials
print_status "Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

# Create database password parameter
print_status "Creating database password parameter..."
aws ssm put-parameter \
    --name "/cmis/database/password" \
    --value "$(openssl rand -base64 32)" \
    --type "SecureString" \
    --overwrite \
    --region $AWS_REGION

# Deploy CloudFormation stack
print_status "Deploying CloudFormation stack..."
aws cloudformation deploy \
    --template-file aws-deployment.yml \
    --stack-name $STACK_NAME \
    --parameter-overrides \
        KeyPairName=$KEY_PAIR_NAME \
        InstanceType=$INSTANCE_TYPE \
    --capabilities CAPABILITY_IAM \
    --region $AWS_REGION

# Get stack outputs
print_status "Getting deployment information..."
INSTANCE_IP=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $AWS_REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`PublicIP`].OutputValue' \
    --output text)

DB_ENDPOINT=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $AWS_REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`DatabaseEndpoint`].OutputValue' \
    --output text)

APP_URL=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $AWS_REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`ApplicationURL`].OutputValue' \
    --output text)

print_status "Deployment completed successfully!"
echo ""
echo "📋 Deployment Information:"
echo "  Instance IP: $INSTANCE_IP"
echo "  Database Endpoint: $DB_ENDPOINT"
echo "  Application URL: $APP_URL"
echo ""
echo "🔧 Next Steps:"
echo "  1. SSH into the instance: ssh -i your-key.pem ec2-user@$INSTANCE_IP"
echo "  2. Check application status: docker-compose -f docker-compose.prod.yml ps"
echo "  3. View application logs: docker-compose -f docker-compose.prod.yml logs"
echo "  4. Access the application at: $APP_URL"
echo ""
echo "📊 Monitoring:"
echo "  - Check CloudWatch logs for application monitoring"
echo "  - Set up CloudWatch alarms for resource monitoring"
echo "  - Configure Route 53 for custom domain (optional)"
echo ""
print_status "Deployment script completed! 🎉"
