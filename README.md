# Self-Service Infrastructure Demo
## HCP Terraform Private Registry with AI/MCP Agent Automation

> 🎓 **This is a hands-on exercise to demonstrate AI-assisted infrastructure workflows using MCP (Model Context Protocol) and agent automation.**

## 🎯 Learning Objectives

This demo teaches you how to:
1. **Use AI agents** to automate Terraform module development and publishing
2. **Leverage MCP Server** (Terraform MCP Server) for infrastructure automation
3. **Build infrastructure as a product** with platform teams enabling developers
4. **Demonstrate two perspectives**: Platform Team creating modules, Developers consuming them

## 📖 The Story

**Platform Team Perspective:**
- Create a reusable Terraform module for web servers
- Publish it to HCP Terraform Private Registry
- Make it a "product" that developers can self-serve

**Developer Perspective:**
- Need to deploy a Node.js application
- Don't know Terraform or AWS
- Use platform team's module with just 3 simple variables

**The Power:** AI agents help both personas accomplish their goals faster and with less expertise!

## 🏗️ Architecture

```
Platform Team                    Private Registry                 Developer
     │                                  │                              │
     ├──> Creates Module                │                              │
     │    (VPC, EC2, Security)          │                              │
     │                                   │                              │
     ├──> Publishes to GitHub ──────────┤                              │
     │                                   │                              │
     └──> Registers in Registry ────────┤                              │
                                         │                              │
                                         │ <──── Discovers Module ─────┤
                                         │                              │
                                         │ ────> Uses Module (3 vars) ─┤
                                         │                              │
                                                                        │
                                                                Infrastructure
                                                                  Deployed! ✅
```

## 🚀 Prerequisites

### Required Tools
- **GitHub Copilot / AI Agent**: For code generation and automation
- **Terraform MCP Server**: Enabled in your IDE (VS Code with MCP support)
- **GitHub CLI**: `gh` command
- **Terraform CLI**: `terraform` command
- **HCP Terraform Account**: With organization created
- **AWS Access**: Via Doormat for credentials

### Required Credentials

```bash
# GitHub token (for pushing code)
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxx"

# HCP Terraform token (for registry and runs)
export TFE_TOKEN="xxxxxxxxxxxxx.atlasv1.xxxxxxxxxxxxx"

# AWS credentials (via Doormat)
doormat aws --account <your-account> --role <your-role>
```

### Configuration

Create your configuration file:
```bash
cp .demo-config.example .demo-config
vim .demo-config
```

Set these values:
```bash
export GITHUB_USER="your-github-username"
export TFC_ORG="org-xxxxxxxxxxxxx"  # Your HCP Terraform org ID
```

Load configuration:
```bash
source .demo-config
```

## 📁 Project Structure

```
.
├── platform-module/
│   └── terraform-webserver/          # Platform team's module
│       ├── main.tf                   # Infrastructure code (VPC, EC2, etc.)
│       ├── variables.tf              # Simple inputs for developers
│       ├── outputs.tf                # Server info & credentials
│       ├── versions.tf               # Provider requirements
│       └── user-data.sh              # Server initialization script
│
├── developer-workflow/
│   └── deploy-webapp/                # Developer's consumption project
│       ├── main.tf                   # Uses module with 3 variables
│       └── app/                      # Node.js application
│           ├── server.js             # Express web server
│           └── package.json          # Dependencies
│
└── .demo-config.example              # Configuration template
```

---

# 🏗️ PART 1: Platform Team Perspective

**Goal:** Create and publish a reusable Terraform module that developers can use without infrastructure expertise.

## Step 1: Understand the Module

First, review what the platform team has created:

**📂 Navigate to the module:**
```bash
cd platform-module/terraform-webserver
```

**🤖 Ask your AI agent:**
```
"Analyze the Terraform module in this directory. What infrastructure does it create? 
What are the developer-facing variables? Explain the abstraction this provides."
```

**Expected Understanding:**
- Module creates: VPC, subnet, security group, EC2 instance, SSH keys
- Input variables: Only 3 simple choices (app name, environment, region)
- Abstraction: Hides all AWS complexity from developers

## Step 2: Validate the Module

**🤖 Use AI agent to validate:**
```
"Validate this Terraform module. Run terraform init and terraform validate. 
Check for any errors or improvements needed."
```

**Manual commands (if needed):**
```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt

# Check for issues
terraform plan -var="application_name=test"
```

**✅ Success criteria:** Module initializes and validates without errors.

## Step 3: Create GitHub Repository for Module

**🤖 Ask AI agent with MCP:**
```
"Create a new public GitHub repository called 'terraform-webserver' for this module.
Initialize git, commit the module files, and push to the new repo.
Tag it as v1.0.0."
```

**What the agent should do (using MCP tools):**

1. **Initialize git repository:**
   ```bash
   git init
   git add .
   git commit -m "feat: web server no-code module v1.0.0"
   ```

2. **Create GitHub repository:**
   ```bash
   gh repo create terraform-webserver \
     --public \
     --description "No-code web server module for HCP Terraform" \
     --source=. \
     --push
   ```

3. **Tag version:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

**✅ Success criteria:** Repository exists at `https://github.com/{GITHUB_USER}/terraform-webserver` with v1.0.0 tag.

## Step 4: Register Module in Private Registry

This step requires manual interaction with HCP Terraform UI:

**📋 Manual steps:**

1. **Open HCP Terraform:**
   ```
   https://app.terraform.io/app/{YOUR_ORG}/registry/modules/new
   ```

2. **Connect to GitHub:**
   - Click "Connect to GitHub"
   - Authorize HCP Terraform if prompted
   - Select your GitHub organization

3. **Select Repository:**
   - Find: `{GITHUB_USER}/terraform-webserver`
   - Click to select it

4. **Publish Module:**
   - Click "Publish module"
   - Wait for processing

5. **Verify Publication:**
   - Module should appear at:
   ```
   app.terraform.io/{YOUR_ORG}/webserver/aws
   ```

**🤖 Alternative - Use Terraform MCP Server tools:**
```
"Using the Terraform MCP Server, help me register the module 
terraform-webserver from my GitHub account into the HCP Terraform 
Private Registry for organization {YOUR_ORG}"
```

**✅ Success criteria:** Module appears in your private registry and can be referenced by developers.

## Step 5: Test Module from Registry

**🤖 Ask AI agent:**
```
"Create a simple test configuration that uses the module from private registry.
Use these values: app_name=test, environment=dev, region=east-us.
Run a plan to verify it works."
```

**Test configuration (test.tf):**
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "test_server" {
  source  = "app.terraform.io/{YOUR_ORG}/webserver/aws"
  version = "1.0.0"
  
  application_name = "test"
  environment      = "dev"
  region_choice    = "east-us"
}
```

**Run plan:**
```bash
terraform init
terraform plan
```

**✅ Success criteria:** Plan shows infrastructure that will be created without errors.

---

# 👨‍💻 PART 2: Developer Perspective

**Goal:** Deploy a web application using the platform team's module without needing infrastructure expertise.

## Step 1: Explore the Developer Project

**📂 Navigate to developer project:**
```bash
cd ../../developer-workflow/deploy-webapp
```

**🤖 Ask AI agent:**
```
"I'm a developer with a Node.js application. Show me what infrastructure 
code I need to deploy it. Explain main.tf in simple terms."
```

**Expected Response:**
- Developer only needs to set 3 variables
- Module handles all infrastructure complexity
- No AWS or Terraform knowledge required

## Step 2: Review the Application

**🤖 Ask AI agent:**
```
"Analyze the Node.js application in the app/ directory. 
What does it do? What port does it run on?"
```

**Expected Understanding:**
- Express web server on port 3000
- Customer portal with REST API
- Will be proxied through Nginx

## Step 3: Configure Infrastructure Code

**🤖 Ask AI agent:**
```
"Update main.tf to use my organization's module. 
My org ID is: {YOUR_ORG}
Keep the application_name as 'customer-portal', 
environment as 'dev', and region as 'east-us'."
```

**The agent should update:**
```hcl
module "my_server" {
  source  = "app.terraform.io/{YOUR_ORG}/webserver/aws"
  version = "1.0.0"
  
  application_name = "customer-portal"
  environment      = "dev"
  region_choice    = "east-us"
}
```

## Step 4: Deploy Infrastructure

**🤖 Use Terraform MCP Server:**
```
"Initialize and apply this Terraform configuration. 
Show me what will be created before applying."
```

**What the agent should do:**

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Review plan:**
   ```bash
   terraform plan
   ```
   
   Expected resources:
   - AWS VPC
   - Subnet
   - Internet Gateway
   - Route Table
   - Security Group
   - EC2 Instance
   - SSH Key Pair

3. **Apply configuration:**
   ```bash
   terraform apply
   ```
   
   Type `yes` when prompted

**⏱️ Wait time:** ~2-3 minutes for infrastructure to be created

**✅ Success criteria:** Terraform completes successfully and outputs server information.

## Step 5: Deploy Application

**🤖 Ask AI agent:**
```
"Help me deploy my Node.js application to the server.
1. Get the server IP from terraform output
2. Save the SSH key
3. SCP the application files
4. SSH in and start the application"
```

**What the agent should do:**

1. **Get server information:**
   ```bash
   SERVER_IP=$(terraform output -raw server_ip)
   echo "Server IP: $SERVER_IP"
   ```

2. **Save SSH key:**
   ```bash
   terraform output -raw ssh_private_key > customer-portal-key.pem
   chmod 400 customer-portal-key.pem
   ```

3. **Wait for initialization:**
   ```bash
   echo "Waiting 60 seconds for server initialization..."
   sleep 60
   ```

4. **Deploy application:**
   ```bash
   # Copy application files
   scp -o StrictHostKeyChecking=no \
       -i customer-portal-key.pem \
       -r ./app ec2-user@$SERVER_IP:/home/ec2-user/
   
   # Install dependencies
   ssh -o StrictHostKeyChecking=no \
       -i customer-portal-key.pem \
       ec2-user@$SERVER_IP \
       "cd app && npm install"
   
   # Start application
   ssh -o StrictHostKeyChecking=no \
       -i customer-portal-key.pem \
       ec2-user@$SERVER_IP \
       "cd app && nohup npm start > app.log 2>&1 &"
   ```

5. **Get application URL:**
   ```bash
   terraform output -raw http_url
   ```

**✅ Success criteria:** Application is accessible at the HTTP URL shown in outputs.

## Step 6: Verify Deployment

**🤖 Ask AI agent:**
```
"Open the application URL in my browser and verify it's running.
Also show me how to check the application logs."
```

**Manual verification:**

1. **Open URL:**
   ```bash
   open $(terraform output -raw http_url)
   ```
   
2. **Check logs:**
   ```bash
   ssh -i customer-portal-key.pem \
       ec2-user@$(terraform output -raw server_ip) \
       "cat app/app.log"
   ```

**Expected result:**
- Customer portal webpage loads
- Shows "Customer Portal - Platform Demo"
- API endpoints work: `/api/customers`, `/api/health`, `/api/info`

---

# 🎓 Learning Exercises

## Exercise 1: Change Environment to Production

**Challenge:** Update the deployment to use production settings.

**🤖 Ask AI agent:**
```
"I need to deploy this to production. What do I change in main.tf?
Show me the diff and explain what will be different."
```

**Expected change:**
```hcl
environment = "prod"  # was "dev"
```

**Expected outcomes:**
- Instance size changes from t3.small to t3.large
- Production-grade settings applied

**Steps:**
1. Update main.tf
2. Run `terraform plan` to see changes
3. Run `terraform apply` to update

## Exercise 2: Add Custom Domain Support

**Challenge:** Modify the module to support custom domain names.

**🤖 Ask AI agent:**
```
"How would I add custom domain support to this module?
Show me what variables to add and what resources need updating."
```

**Expected additions:**
- New variable: `domain_name` (optional)
- Resources: Route53 zone/records or CloudFront
- Outputs: Domain URL

## Exercise 3: Multi-Region Deployment

**Challenge:** Deploy the same application to multiple regions.

**🤖 Ask AI agent:**
```
"I want to deploy this application to both east-us and west-us.
How can I use the module twice in the same configuration?"
```

**Expected solution:**
```hcl
module "east_server" {
  source = "app.terraform.io/{ORG}/webserver/aws"
  version = "1.0.0"
  
  application_name = "customer-portal"
  environment      = "dev"
  region_choice    = "east-us"
}

module "west_server" {
  source = "app.terraform.io/{ORG}/webserver/aws"
  version = "1.0.0"
  
  application_name = "customer-portal"
  environment      = "dev"
  region_choice    = "west-us"
}
```

## Exercise 4: Cost Optimization

**Challenge:** Use Terraform MCP Server to analyze costs.

**🤖 Ask AI agent with MCP:**
```
"Analyze the cost of this infrastructure. What's the monthly estimate?
How can I reduce costs for development environments?"
```

**Expected analysis:**
- Current cost: ~$15/month (t3.small)
- Optimization ideas: Spot instances, auto-shutdown, smaller instances

## Exercise 5: Security Audit

**Challenge:** Review security posture of the module.

**🤖 Ask AI agent:**
```
"Audit the security of this Terraform module. 
Check for: open ports, encryption, IAM policies, public access.
Suggest improvements."
```

**Expected findings:**
- Security group rules review
- Encryption at rest/transit
- IMDSv2 enforcement
- Least privilege access

---

# 🧹 Cleanup

When done with the exercise, destroy all resources:

**🤖 Ask AI agent:**
```
"Destroy all infrastructure created by this project. 
Show me what will be destroyed first."
```

**Manual commands:**
```bash
cd developer-workflow/deploy-webapp

# Review what will be destroyed
terraform plan -destroy

# Destroy infrastructure
terraform destroy -auto-approve

# Clean up local files
rm -f *.pem *.key
rm -rf .terraform
```

**Cost:** Demo runs for ~3 hours = less than $0.50

---

# 🎯 Key Takeaways

## For Platform Teams:
1. **Abstraction is power** - Hide complexity, expose simplicity
2. **Modules as products** - Treat infrastructure like product offerings
3. **Version and test** - Maintain quality like any software
4. **Documentation matters** - Make it easy for developers to self-serve

## For Developers:
1. **Self-service is possible** - Infrastructure doesn't require expertise
2. **Simple variables, complex results** - Module handles everything
3. **Fast iteration** - Infrastructure in minutes, not weeks
4. **Focus on apps** - Spend time on business logic, not infrastructure

## For AI/MCP Usage:
1. **Automate the tedious** - Let AI handle boilerplate and validation
2. **MCP tools are powerful** - Terraform MCP Server streamlines workflows
3. **Iterate faster** - AI helps you explore options quickly
4. **Learn by doing** - AI guides you through exercises

---

# 🔧 Troubleshooting

## Module not found in registry
**Solution:** Verify module is published in HCP Terraform UI, not just GitHub

**🤖 Ask AI agent:**
```
"Check if my module terraform-webserver is published in the private registry.
Organization: {YOUR_ORG}"
```

## Terraform init fails
**Solution:** Check organization name matches in main.tf

**🤖 Ask AI agent:**
```
"My terraform init fails. Verify the module source path is correct.
My org: {YOUR_ORG}"
```

## AWS credentials expired
**Solution:** Refresh Doormat credentials

```bash
doormat logout
doormat aws --account <account> --role <role>
```

## Application not accessible
**Solution:** Wait for initialization and check security groups

**🤖 Ask AI agent:**
```
"My application isn't accessible. Help me debug:
1. Check if server is responding
2. Verify security group rules
3. Check nginx status"
```

## SSH connection refused
**Solution:** Verify key permissions and server is ready

```bash
chmod 400 customer-portal-key.pem
# Wait 2-3 minutes for server initialization
```

---

# 📚 Additional Resources

## Documentation
- [HCP Terraform Private Registry](https://developer.hashicorp.com/terraform/cloud-docs/registry)
- [Terraform Module Development](https://developer.hashicorp.com/terraform/language/modules/develop)
- [MCP (Model Context Protocol)](https://modelcontextprotocol.io/)
- [Terraform MCP Server](https://github.com/hashicorp/terraform-mcp-server)

## Next Steps
1. **Create more modules** - Database, networking, monitoring
2. **Implement no-code provisioning** - HCP Terraform UI workflows
3. **Add policy enforcement** - Sentinel or OPA policies
4. **Enable cost controls** - Budget alerts and limits
5. **Build a module library** - Full platform offering

---

**🚀 This exercise demonstrates the power of combining AI agents, MCP automation, and infrastructure as code to enable self-service infrastructure!**

**Key insight:** Platform teams create the "products" (modules), developers consume them without expertise, and AI agents accelerate both workflows.
