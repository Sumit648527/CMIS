# 🚀 CMIS Deployment Guide

## 📋 Overview

This guide covers the complete deployment of the CMIS (College Management Information System) to AWS with CI/CD pipeline, testing, and code quality analysis.

## ✅ Implemented Features

### 🧪 Testing & Code Quality
- ✅ **Jest + Supertest** for backend unit testing
- ✅ **Vitest + Testing Library** for frontend component testing
- ✅ **SonarQube** integration for code quality analysis
- ✅ **Code coverage** reporting
- ✅ **Mocking** with Jest mocks for Prisma and external dependencies

### ☁️ AWS Deployment
- ✅ **CloudFormation** template for infrastructure as code
- ✅ **EC2** instance with Docker support
- ✅ **RDS PostgreSQL** database
- ✅ **VPC** with public/private subnets
- ✅ **Security Groups** with proper access controls
- ✅ **Production Docker** images with multi-stage builds

### 🔄 CI/CD Pipeline
- ✅ **GitHub Actions** workflow
- ✅ **Automated testing** on every commit
- ✅ **Docker image** building and pushing to ECR
- ✅ **AWS deployment** automation
- ✅ **Security scanning** with Trivy
- ✅ **Code quality** gates with SonarQube

## 🛠️ Prerequisites

### Required Tools
```bash
# AWS CLI
aws --version

# Docker
docker --version

# Node.js (for local development)
node --version

# Git
git --version
```

### AWS Setup
1. **AWS Account** with appropriate permissions
2. **EC2 Key Pair** created in your region
3. **AWS CLI** configured with credentials
4. **ECR Repository** (will be created automatically)

## 🚀 Quick Deployment

### 1. Clone and Setup
```bash
git clone <your-repo-url>
cd CMIS
```

### 2. Configure Environment
```bash
# Set your AWS region and key pair
export AWS_REGION="us-east-1"
export KEY_PAIR_NAME="your-keypair-name"
```

### 3. Deploy to AWS
```bash
# Make deployment script executable (Linux/Mac)
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

### 4. Access Your Application
After deployment, you'll get:
- **Application URL**: `http://<instance-ip>:3000`
- **API URL**: `http://<instance-ip>:4000/api/v1`
- **Database**: RDS PostgreSQL instance

## 🔧 Manual Deployment Steps

### Step 1: Create Database Password
```bash
aws ssm put-parameter \
    --name "/cmis/database/password" \
    --value "$(openssl rand -base64 32)" \
    --type "SecureString" \
    --overwrite \
    --region us-east-1
```

### Step 2: Deploy Infrastructure
```bash
aws cloudformation deploy \
    --template-file aws-deployment.yml \
    --stack-name cmis-stack \
    --parameter-overrides \
        KeyPairName=your-keypair \
        InstanceType=t3.medium \
    --capabilities CAPABILITY_IAM \
    --region us-east-1
```

### Step 3: Get Deployment Info
```bash
aws cloudformation describe-stacks \
    --stack-name cmis-stack \
    --query 'Stacks[0].Outputs'
```

## 🧪 Running Tests

### Backend Tests
```bash
cd server
npm install
npm test
npm run test:coverage
```

### Frontend Tests
```bash
cd client
npm install
npm test
npm run test:coverage
```

### SonarQube Analysis
```bash
# Start SonarQube
docker-compose -f docker-compose.sonar.yml up -d

# Run analysis
docker-compose -f docker-compose.sonar.yml run sonar-scanner
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow
The pipeline automatically:
1. **Runs tests** on every push/PR
2. **Builds Docker images** on main branch
3. **Pushes to ECR** repository
4. **Deploys to AWS** ECS/EC2
5. **Runs security scans**
6. **Sends notifications**

### Required Secrets
Add these to your GitHub repository secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `SONAR_TOKEN`
- `SLACK_WEBHOOK` (optional)

## 📊 Monitoring & Maintenance

### Application Monitoring
```bash
# SSH into instance
ssh -i your-key.pem ec2-user@<instance-ip>

# Check application status
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Restart services
docker-compose -f docker-compose.prod.yml restart
```

### Database Management
```bash
# Connect to database
psql -h <db-endpoint> -U cmis_admin -d cmis_prod

# Run migrations
npx prisma migrate deploy
```

### Scaling
```bash
# Update instance type
aws cloudformation update-stack \
    --stack-name cmis-stack \
    --template-body file://aws-deployment.yml \
    --parameters ParameterKey=InstanceType,ParameterValue=t3.large
```

## 🔒 Security Features

### Implemented Security
- ✅ **JWT Authentication** with secure tokens
- ✅ **Role-based access control** (Admin, Staff, Student)
- ✅ **Input validation** with Zod schemas
- ✅ **SQL injection protection** with Prisma ORM
- ✅ **CORS** configuration
- ✅ **Security headers** in production
- ✅ **Vulnerability scanning** with Trivy
- ✅ **Secrets management** with AWS SSM

### Security Best Practices
- Database passwords stored in AWS SSM Parameter Store
- Non-root user in Docker containers
- Security groups with minimal required access
- Regular security updates via CI/CD

## 🎯 Performance Optimizations

### Backend Optimizations
- ✅ **Connection pooling** with Prisma
- ✅ **Caching** strategies
- ✅ **Compression** middleware
- ✅ **Health checks** for containers

### Frontend Optimizations
- ✅ **Code splitting** with Vite
- ✅ **Tree shaking** for smaller bundles
- ✅ **Image optimization**
- ✅ **Lazy loading** components

## 📈 Cost Optimization

### AWS Cost Management
- **t3.medium** instance (can be scaled down to t3.small for development)
- **db.t3.micro** RDS instance
- **S3** for static assets (optional)
- **CloudWatch** for monitoring

### Estimated Monthly Costs
- EC2 t3.medium: ~$30/month
- RDS db.t3.micro: ~$15/month
- Data transfer: ~$5/month
- **Total**: ~$50/month

## 🆘 Troubleshooting

### Common Issues

#### Application Not Starting
```bash
# Check Docker logs
docker-compose -f docker-compose.prod.yml logs

# Check system resources
df -h
free -m
```

#### Database Connection Issues
```bash
# Check database status
aws rds describe-db-instances --db-instance-identifier cmis-database

# Test connection
telnet <db-endpoint> 5432
```

#### CI/CD Pipeline Failures
- Check GitHub Actions logs
- Verify AWS credentials
- Ensure all required secrets are set

## 📚 Additional Resources

### Documentation
- [AWS CloudFormation](https://docs.aws.amazon.com/cloudformation/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Jest Testing](https://jestjs.io/docs/getting-started)
- [SonarQube](https://docs.sonarqube.org/)

### Support
- Check GitHub Issues for common problems
- Review AWS CloudWatch logs for application issues
- Monitor SonarQube for code quality issues

---

## 🎉 Congratulations!

Your CMIS application is now fully deployed with:
- ✅ **Production-ready** infrastructure
- ✅ **Automated testing** and deployment
- ✅ **Code quality** monitoring
- ✅ **Security** best practices
- ✅ **Scalable** architecture

**Your application is live and ready for use!** 🚀
