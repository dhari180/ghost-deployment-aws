## Infrastructure as Code Automation for Ghost CMS Deployment using Terraform on AWS

---

## Repository Summary

This Terraform repository provisions the following on **AWS**:

- **Ghost CMS Deployment**: A containerized Ghost blogging platform running on AWS ECS Fargate
- **Complete VPC Infrastructure**: Custom VPC with 3 public and 3 private subnets across availability zones, Internet Gateway, and NAT Gateway
- **Database Layer**: RDS MySQL 8.0 instance in private subnets for persistent Ghost data storage
- **Load Balancing**: Application Load Balancer with Blue/Green deployment target groups
- **Full CI/CD Pipeline**: AWS CodePipeline integrating CodeCommit, CodeBuild, CodeDeploy, and ECR for automated container deployments
- **State Management**: Remote S3 backend for Terraform state

---

## Introduction

**Infrastructure as Code Automation for Ghost CMS Deployment using Terraform on AWS**

- **Presented by:** Dhari Alaibani, Naser Alshbal, Abdulaziz Alenezi
- **Supervisor:** Paul Thornley

---

## Abstract

Modern web applications require reliable, reproducible, and scalable cloud infrastructure. This project addresses the challenges of manual cloud provisioning by implementing a fully automated Infrastructure as Code (IaC) solution using Terraform to deploy the Ghost content management system on Amazon Web Services.

The solution provisions a complete production grade environment including a custom Virtual Private Cloud, containerized application services using ECS Fargate, a managed MySQL database, and a fully integrated CI/CD pipeline using AWS Developer Tools. The outcome demonstrates significant improvements in deployment consistency, reduced human error, and streamlined release workflows.

---

## Problem Statement

**Challenges with Manual Cloud Infrastructure Provisioning:**

- **Time Consuming Setup**: Manually clicking through the AWS Console to create VPCs, subnets, security groups, databases, and container services takes hours and requires constant attention
- **Human Error Risk**: Misconfigured security groups, incorrect subnet associations, or forgotten route tables can lead to security vulnerabilities or application failures
- **Lack of Reproducibility**: Recreating the same environment for staging, testing, or disaster recovery becomes nearly impossible when configured manually
- **Configuration Drift**: Over time, manual changes in production environments deviate from documented architecture, causing inconsistencies
- **Poor Collaboration**: No version history or peer review process for infrastructure changes
- **Complex CI/CD Integration**: Setting up continuous deployment pipelines manually involves coordinating multiple AWS services with intricate IAM permissions

**Specific Context:** Deploying a containerized web application (Ghost CMS) requires networking, compute, database, load balancing, and pipeline orchestration, all of which are error prone when done manually.

---

## Proposed Solution

**Terraform Based Automated Infrastructure Provisioning for Ghost CMS on AWS**

- **Declarative Infrastructure Definition**: All cloud resources defined in version controlled Terraform configuration files
- **Modular Architecture**: Separation of concerns with dedicated modules for infrastructure (VPC, ECS, RDS, Load Balancer) and CI/CD (CodePipeline, CodeBuild, CodeDeploy)
- **End-to-End Automation**: From network foundation to application deployment pipeline, every component is codified
- **Blue/Green Deployment Strategy**: Zero-downtime deployments with automatic rollback capability
- **Remote State Management**: Terraform state stored in S3 for team collaboration and state integrity

**How This Addresses the Problems:**

| Problem | Solution |
|---------|----------|
| Manual setup time | Single `terraform apply` provisions all resources |
| Human error | Validated, tested code replaces manual clicks |
| No reproducibility | Same code deploys identical environments |
| Configuration drift | Git history tracks all changes |

---

## Why Terraform?

**Key Advantages of Terraform for IaC:**

- **Declarative Syntax**: Define the desired end state; Terraform figures out how to achieve it
- **Reproducibility**: Same configuration produces identical infrastructure every time
- **Modularity**: Reusable modules encapsulate complexity and promote DRY (Don't Repeat Yourself) principles
- **Version Control Integration**: Infrastructure changes are tracked, reviewed, and auditable through Git
- **State Management**: Terraform maintains a state file to track real world resources and detect drift
- **Multi-Cloud Support**: While this project uses AWS, Terraform supports Azure, GCP, and 1000+ providers

**Comparison with Alternatives:**

- Unlike AWS CloudFormation (AWS only), Terraform is cloud agnostic and has a larger ecosystem
- Unlike manual provisioning, Terraform provides idempotent, repeatable deployments

---

## Project Scope

**Components Provisioned by This Repository:**

### Networking
- Custom VPC with CIDR block `10.0.0.0/16`
- 3 Public Subnets (for Load Balancer and NAT Gateway)
- 3 Private Subnets (for ECS tasks and RDS database)
- Internet Gateway for public internet access
- NAT Gateway with Elastic IP for private subnet outbound traffic
- Route Tables for public and private traffic routing

### Compute
- ECS Cluster running on AWS Fargate (serverless containers)
- ECS Task Definition (1 vCPU, 2 GB memory) running Ghost CMS container
- ECS Service with Blue/Green deployment controller

### Database
- RDS MySQL 8.0 instance (`db.t3.micro`, 20 GB storage)
- Database Subnet Group spanning private subnets

### Load Balancing
- Application Load Balancer (internet facing)
- HTTP Listener on port 80
- Two Target Groups for Blue/Green traffic switching

### Security/Identity
- Load Balancer Security Group (allows HTTP port 80)
- ECS Tasks Security Group (allows port 2368 from LB only)
- RDS Security Group (allows MySQL port 3306 from ECS only)
- IAM Roles for ECS Task Execution, CodeBuild, CodeDeploy, and CodePipeline

### CI/CD Pipeline
- AWS CodeCommit repository for Ghost application source code
- AWS ECR repository for Docker container images (with scan on push enabled)
- AWS CodeBuild project for Docker image building
- AWS CodeDeploy application with Blue/Green deployment strategy
- AWS CodePipeline orchestrating Source → Build → Deploy stages
- S3 bucket for pipeline artifacts with versioning enabled

### Monitoring/Logging
- CloudWatch Log Group for ECS container logs (30 days retention)

---

## Architecture Diagram

**High-Level Architecture Overview:**

```
                        ┌─────────────────────────────────────────────────────────────┐
                        │                         AWS Cloud                           │
                        │  ┌───────────────────────────────────────────────────────┐  │
         Internet       │  │                    VPC (10.0.0.0/16)                  │  │
            │           │  │                                                       │  │
            ▼           │  │   ┌─────────────────────────────────────────────┐     │  │
    ┌───────────────┐   │  │   │           Public Subnets (x3 AZs)           │     │  │
    │    Users      │───┼──┼──▶│  ┌─────────────┐      ┌──────────────┐      │     │  │
    └───────────────┘   │  │   │  │   Internet  │      │     NAT      │      │     │  │
                        │  │   │  │   Gateway   │      │   Gateway    │      │     │  │
                        │  │   │  └──────┬──────┘      └──────┬───────┘      │     │  │
                        │  │   │         │                    │              │     │  │
                        │  │   │  ┌──────▼──────────────────────────────┐    │     │  │
                        │  │   │  │    Application Load Balancer        │    │     │  │
                        │  │   │  │         (Port 80 HTTP)              │    │     │  │
                        │  │   │  └──────┬─────────────┬────────────────┘    │     │  │
                        │  │   └─────────┼─────────────┼─────────────────────┘     │  │
                        │  │             │ Blue TG     │ Green TG                  │  │
                        │  │   ┌─────────▼─────────────▼─────────────────────┐     │  │
                        │  │   │           Private Subnets (x3 AZs)          │     │  │
                        │  │   │                                             │     │  │
                        │  │   │   ┌─────────────────┐   ┌───────────────┐   │     │  │
                        │  │   │   │   ECS Fargate   │   │  RDS MySQL    │   │     │  │
                        │  │   │   │   (Ghost CMS)   │──▶│   Database    │   │     │  │
                        │  │   │   │   Port 2368     │   │   Port 3306   │   │     │  │
                        │  │   │   └─────────────────┘   └───────────────┘   │     │  │
                        │  │   └─────────────────────────────────────────────┘     │  │
                        │  └───────────────────────────────────────────────────────┘  │
                        └─────────────────────────────────────────────────────────────┘
```

**Data Flow:**
1. **Users** access the Ghost blog via the internet
2. **Internet Gateway** routes traffic into the VPC
3. **Application Load Balancer** (public subnets) receives HTTP requests on port 80
4. **Target Groups** route traffic to ECS tasks (Blue/Green deployment)
5. **ECS Fargate Service** (private subnets) runs Ghost container on port 2368
6. **Ghost Application** connects to RDS MySQL database on port 3306
7. **NAT Gateway** allows ECS tasks to pull Docker images from ECR

**Architectural Tiers:**
- **Client Tier**: End users accessing via web browser
- **Edge/Ingress Tier**: Application Load Balancer in public subnets
- **Application Tier**: ECS Fargate containers in private subnets
- **Data Tier**: RDS MySQL in private subnets
- **Management Tier**: CloudWatch Logs, CI/CD Pipeline, ECR Registry

---

## Terraform Project & Module Structure

**Repository File Structure:**

```
ghost-deployment/
├── main.tf                    # Root module: wires infra and cicd together
├── README.md                  # Project documentation
│
├── modules/
│   ├── infra/                 # Infrastructure Module
│   │   ├── vpc.tf             # VPC, Subnets, IGW, NAT, Route Tables
│   │   ├── ecs.tf             # ECS Cluster, Task Definition, Service, IAM
│   │   ├── rds.tf             # RDS MySQL instance, Subnet Group, Security Group
│   │   ├── lb.tf              # ALB, Listener, Target Groups (Blue/Green)
│   │   ├── sg.tf              # Security Groups for LB and ECS
│   │   ├── data.tf            # Data sources (AZs, Region)
│   │   ├── variables.tf       # Input variables
│   │   └── outputs.tf         # Output values for cicd module
│   │
│   └── cicd/                  # CI/CD Pipeline Module
│       ├── codecommit.tf      # Source code repository
│       ├── ecr.tf             # Docker container registry
│       ├── codebuild.tf       # Build project and IAM
│       ├── codedeploy.tf      # Deployment application and group
│       ├── codepipeline.tf    # Pipeline orchestration and S3 artifacts
│       ├── iam.tf             # IAM roles for CodeDeploy and Pipeline
│       ├── buildspec.yml      # CodeBuild build specification
│       ├── data.tf            # Data sources (Account ID, Region)
│       ├── variables.tf       # Input variables from infra module
│       └── outputs.tf         # ECR repository URL output
```

**Module Responsibilities:**

| Module | Purpose |
|--------|---------|
| **Root (main.tf)** | Configures S3 backend, defines sensitive variables, connects modules with cross-references |
| **infra** | Provisions all AWS infrastructure: networking, compute, database, load balancing, security |
| **cicd** | Provisions the complete CI/CD pipeline for automated container deployments |

**Module Interconnection:**
- The `infra` module outputs values (ECS cluster name, service name, target group, listener ARN, RDS endpoint) that the `cicd` module consumes as input variables
- The `cicd` module outputs the ECR repository URL which the `infra` module uses for container image references

---

## State Management

**Terraform State in This Project:**

- **Backend Type**: Remote (AWS S3)
- **State File Location**: `s3://ghost-terraform-bucket-6-11-2023-01-12/terraform.tfstate`
- **Region**: `eu-west-1` (Ireland)

**Configuration in `main.tf`:**
```hcl
terraform {
  backend "s3" {
    bucket = "ghost-terraform-bucket-6-11-2023-01-12"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}
```

**Why State Management Matters:**

- **Resource Tracking**: Terraform uses state to map configuration to realworld resources
- **Change Detection**: Determines what needs to be created, updated, or destroyed
- **Dependency Resolution**: Understands the order of operations based on resource relationships
- **Team Collaboration**: Remote state allows multiple team members to work on the same infrastructure
- **Disaster Recovery**: State file can be used to import or recreate infrastructure

**Current State vs. Possible Improvement:**
- **Current**: S3 backend without state locking
- **Improvement**: Add DynamoDB table for state locking to prevent concurrent modifications

---

## CI/CD Pipeline Workflow

**Automated Deployment Pipeline (AWS CodePipeline):**

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                            AWS CodePipeline                                  │
│                                                                              │
│   ┌─────────────┐      ┌─────────────┐      ┌─────────────────────────┐     │
│   │   SOURCE    │      │    BUILD    │      │         DEPLOY          │     │
│   │             │      │             │      │                         │     │
│   │ CodeCommit  │ ───▶ │  CodeBuild  │ ───▶ │  CodeDeploy (ECS)       │     │
│   │ (main)      │      │             │      │  Blue/Green             │     │
│   └─────────────┘      └─────────────┘      └─────────────────────────┘     │
│         │                    │                         │                    │
│         ▼                    ▼                         ▼                    │
│   Push to 'main'      Docker Build           Traffic Shift to              │
│   branch triggers     Push to ECR            new Task Definition           │
│   pipeline            Generate artifacts     Auto rollback on failure      │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Pipeline Stages Explained:**

1. **Source Stage (CodeCommit)**
   - Monitors the `main` branch of `ghost-app-repository`
   - Triggers on code push/merge
   - Outputs source code as `source_output` artifact

2. **Build Stage (CodeBuild)**
   - Logs into Amazon ECR
   - Builds Docker image from source code
   - Tags and pushes image to ECR registry
   - Generates `taskdef.json` and `appspec.yaml` for deployment
   - Image scanning enabled on push for vulnerability detection

3. **Deploy Stage (CodeDeploy to ECS)**
   - Uses Blue/Green deployment strategy
   - Creates new ECS tasks with updated container image
   - Shifts ALB traffic from Blue to Green target group
   - Terminates old tasks after 5 minutes
   - Automatic rollback if deployment fails

**Pipeline Artifacts:**
- Stored in versioned S3 bucket: `ghost-pipeline-artifacts-bucket-2023-11-05t22-10-52-00-00`

---

## Security Considerations

**Security Design Implemented in This Project:**

### Network Isolation
- **Private Subnets**: ECS tasks and RDS database run in private subnets with no direct internet access
- **NAT Gateway**: Outbound internet access (for pulling images) without exposing private resources
- **Public Subnets**: Only the Load Balancer is publicly accessible

### Security Groups (Defense in Depth)
- **Load Balancer SG**: Allows inbound HTTP (port 80) from anywhere (`0.0.0.0/0`)
- **ECS Tasks SG**: Allows inbound on port 2368 **only from the Load Balancer SG** (not from the internet)
- **RDS SG**: Allows MySQL port 3306 **only from the ECS Tasks SG** (database not accessible from LB or internet)

### IAM Least Privilege
- **ECS Execution Role**: Uses AWS managed `AmazonECSTaskExecutionRolePolicy` with minimum permissions for pulling images and logging
- **CodeBuild Role**: Scoped to ECR push, CloudWatch logs, and CodeCommit read
- **CodeDeploy Role**: Uses AWS managed `AWSCodeDeployRoleForECS` policy
- **CodePipeline Role**: Limited to CodeBuild, CodeCommit, and S3 artifact operations

### Container Security
- **ECR Scan on Push**: Container images are automatically scanned for vulnerabilities when pushed

### Sensitive Data Handling
- **Database Password**: Marked as `sensitive = true` in Terraform variables

**Current State vs. Possible Improvements:**

| Current State | Possible Improvement |
|---------------|---------------------|
| HTTP only (port 80) | Add HTTPS with ACM certificate and redirect HTTP to HTTPS |
| No WAF | Add AWS WAF for Layer 7 protection |
| Basic logging | Add VPC Flow Logs for network traffic analysis |
| No encryption at rest for RDS | Enable RDS encryption with KMS |
| No Secrets Manager | Store database password in AWS Secrets Manager |

---

## Demonstration Flow

**How to Demo This Project:**

### Step 1: Initialize and Plan
```bash
terraform init          # Initialize providers and backend
terraform plan          # Preview infrastructure changes
```
- Show the plan output highlighting ~25+ resources to be created
- Explain the dependency graph (VPC → Subnets → ECS → Pipeline)

### Step 2: Apply Infrastructure
```bash
terraform apply -auto-approve
```
- Watch resources being created in sequence
- Highlight outputs: ALB DNS name, RDS endpoint, ECR repository URL

### Step 3: Verify in AWS Console
- Show the VPC with subnets in the VPC Dashboard
- Navigate to ECS → Cluster → Service showing running task
- Show the RDS instance in private subnets
- Display the CodePipeline with three stages

### Step 4: Access the Application
- Open the ALB DNS name in a browser
- Show the Ghost CMS setup/admin page
- Demonstrate the application is live and connected to MySQL

### Step 5: Trigger CI/CD Pipeline (Optional)
- Push a code change to CodeCommit
- Watch the pipeline automatically trigger
- Observe Blue/Green deployment in progress

---

## Results & Benefits

**Practical Impact of This Terraform Implementation:**

### Reproducibility
- Entire infrastructure can be recreated from code in any AWS region
- Same configuration deploys identical dev, staging, and production environments
- Disaster recovery: infrastructure can be rebuilt from scratch in under 30 minutes

### Time Savings
- **Manual Setup Estimate**: 4–6 hours to configure VPC, ECS, RDS, ALB, and CI/CD through console
- **Terraform Deployment**: ~15 minutes for initial `terraform apply`
- **Subsequent Changes**: Minutes instead of hours, with automatic dependency management

### Reduced Human Error
- Security group rules are defined once, not retyped in console
- Subnet CIDR blocks and route tables are automatically calculated
- IAM policies are version controlled and peer reviewed

### Zero-Downtime Deployments
- Blue/Green deployment strategy ensures application availability during updates
- Automatic rollback on deployment failure prevents broken releases

### Audit Trail
- Every infrastructure change is tracked in Git history
- Infrastructure changes require code review before merging

### Cost Visibility
- All resources are documented in code
- Easy to identify and remove unused resources

---

## Challenges Faced

**Technical Challenges Encountered and Solutions:**

### 1. Module Dependency Management
- **Challenge**: The CI/CD module requires outputs from the infrastructure module (ECS cluster name, service name, target group), but both modules are defined in the same root configuration
- **Solution**: Used Terraform's implicit dependency resolution through module output references (`module.infra.ecs_cluster_name`)

### 2. Circular Reference Between Modules
- **Challenge**: The infra module needs the ECR repository URL for the task definition, but ECR is defined in the cicd module
- **Solution**: Used the official `ghost:latest` image for initial deployment; subsequent deployments use the ECR image via CI/CD pipeline

### 3. ECS Service with Blue/Green Deployment
- **Challenge**: ECS service managed by CodeDeploy should not have its task definition or load balancer updated by Terraform after initial creation
- **Solution**: Added `lifecycle { ignore_changes = [task_definition, load_balancer] }` to prevent Terraform from reverting CodeDeploy changes

### 4. IAM Permission Scoping
- **Challenge**: Determining the minimum IAM permissions required for CodeBuild, CodeDeploy, and CodePipeline
- **Solution**: Started with broader permissions during development, then iteratively tightened based on CloudTrail logs and access denied errors

### 5. State File Security
- **Challenge**: Ensuring Terraform state (which contains sensitive outputs) is not accidentally exposed
- **Solution**: Used S3 backend with private bucket; state is not committed to Git

### 6. Database Credentials Management
- **Challenge**: Passing the database password securely through the pipeline
- **Solution**: Used Terraform sensitive variables and CodeBuild environment variables (future improvement: use Secrets Manager)

---

## Future Work

**Proposed Enhancements for This Project:**

### Security Improvements
- **HTTPS/TLS**: Add AWS Certificate Manager (ACM) certificate and configure HTTPS on the load balancer
- **Secrets Manager Integration**: Store database credentials in AWS Secrets Manager instead of environment variables
- **WAF Integration**: Add AWS Web Application Firewall to protect against common web exploits
- **VPC Flow Logs**: Enable flow logs for network traffic auditing
- **RDS Encryption**: Enable encryption at rest using AWS KMS

### Infrastructure Hardening
- **State Locking**: Add DynamoDB table for Terraform state locking to prevent concurrent modifications
- **Multi-Region Deployment**: Extend the infrastructure for disaster recovery in a secondary region
- **Auto Scaling**: Add ECS Service Auto Scaling based on CPU/memory utilization
- **Private ECR Endpoint**: Add VPC endpoint for ECR to avoid NAT Gateway data transfer costs

### CI/CD Enhancements
- **Manual Approval Stage**: Add a manual approval step before production deployment
- **Automated Testing**: Integrate container tests in the CodeBuild phase
- **Slack/Email Notifications**: Add SNS notifications for pipeline success/failure

### DevSecOps Practices
- **Terraform Security Scanning**: Integrate `tfsec` or `Checkov` to scan Terraform code for security misconfigurations
- **Container Vulnerability Reports**: Surface ECR scan results in the pipeline
- **Infrastructure Tests**: Add Terratest for automated infrastructure validation

### Developer Experience
- **Terraform Workspaces**: Implement workspaces for environment separation (dev/staging/prod)
- **Self Service Portal**: Build an internal portal for developers to deploy preview environments

---

## Conclusion

**Key Takeaways:**

- **Problem Addressed**: Manual cloud infrastructure provisioning is slow, error prone, and difficult to reproduce. This project demonstrates how Infrastructure as Codeeliminates these challenges.

- **Solution Delivered**: A fully automated Terraform based solution that provisions a production-grade Ghost CMS environment on AWS, including:
  - Complete network infrastructure (VPC, subnets, gateways)
  - Containerized application platform (ECS Fargate)
  - Managed database (RDS MySQL)
  - Load balancing with Blue/Green deployments
  - End-to-end CI/CD pipeline (CodePipeline, CodeBuild, CodeDeploy)

- **Business Value**: Infrastructure can now be deployed in minutes instead of hours, with full auditability, version control, and zero downtime deployment capability.

- **Technical Skills Demonstrated**:
  - HashiCorp Terraform and HCL syntax
  - AWS services: VPC, ECS, RDS, ALB, IAM, CodePipeline, CodeBuild, CodeDeploy, ECR, CloudWatch
  - Infrastructure as Codebest practices
  - CI/CD pipeline design
  - Network security architecture
  - Container orchestration concepts

- **Lessons Learned**: Modular design, state management, and security-first architecture are essential for maintainable cloud infrastructure.

---

## Q&A

# Questions?

**Thank you for your attention.**

---

**Contact:**
- **Name:** Naser Alshbal, Dhari Alaibani, Abdulaziz Alenezi
- **Email:** c2065700@hallam.shu.ac.uk, c1057824@hallam.shu.ac.uk,c2044125@hallam.shu.ac.uk
- **Github:** https://github.com/dhari180/ghost-deployment-aws

---