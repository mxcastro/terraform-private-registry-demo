# Self-Service Infrastructure Demo
## HCP Terraform Private Registry with MCP Server Automation

A realistic demonstration of **infrastructure as a product** using HCP Terraform Private Registry.

> 🎯 **This demo is fully generic and reusable across customers**

## What This Demo Shows

How platform teams enable developers to provision infrastructure without cloud or Terraform expertise using no-code modules.

**The Scenario:**
- **Developer** builds a Node.js web application
- **Challenge** needs cloud infrastructure but doesn't know Terraform or AWS
- **Solution** uses platform team's no-code module from private registry

**Developer's entire infrastructure code:**
```hcl
module "my_server" {
  source  = "app.terraform.io/YOUR_ORG/webserver/aws"
  version = "1.0.0"
  
  application_name = "customer-portal"
  environment      = "dev"  
  region_choice    = "east-us"
}
```

That's it! Three simple variables.

## 📁 Project Structure

```
.
├── platform-module/
│   └── terraform-webserver/          # Module published to private registry
│       ├── main.tf                   # Creates VPC, EC2, security, etc.
│       ├── variables.tf              # 3 developer-friendly inputs
│       └── outputs.tf                # Server info & credentials
│
├── developer-workflow/
│   └── deploy-webapp/                # Developer's simple project
│       ├── main.tf                   # Uses the module (3 variables!)
│       ├── app/                      # Node.js application code
│       └── deploy.sh                 # One-command deployment
│
├── scripts/setup.sh                  # Automated setup
└── .demo-config.example              # Configuration template
```

## 🚀 Quick Start

### 1. Configure

```bash
# Copy configuration template
cp .demo-config.example .demo-config

# Edit with your values
vim .demo-config
```

Set these variables:
```bash
export GITHUB_USER="your-github-username"
export TFC_ORG="org-xxxxxxxxxxxxx"      # Your HCP Terraform org ID
```

### 2. Prerequisites

```bash
# Load configuration
source .demo-config

# Set tokens
export GITHUB_TOKEN="your-github-token"
export TFE_TOKEN="your-terraform-cloud-token"

# Get AWS credentials via Doormat
doormat aws --account <account> --role <role>
```

### 3. Run Setup

```bash
./scripts/setup.sh
```

This will:
1. Validate the platform module
2. Publish to GitHub: `{GITHUB_USER}/terraform-webserver`
3. Tag version `v1.0.0`
4. Create deployment script

### 4. Register Module in Private Registry

1. Go to: `https://app.terraform.io/app/{YOUR_ORG}/registry/modules/new`
2. Click "Connect to GitHub"
3. Select: `{GITHUB_USER}/terraform-webserver`
4. Click "Publish module"

Module available at: `app.terraform.io/{YOUR_ORG}/webserver/aws`

### 5. Deploy

```bash
cd developer-workflow/deploy-webapp

# Update main.tf with your org name
vim main.tf  # Change YOUR_ORG to your actual org

# Deploy
./deploy.sh
```

### 6. Demo! 🎉

Open the URL from terraform output - the customer portal is running!

## 🎬 Demo Walkthrough (10 minutes)

### 1. Show the Problem (1 min)
Developers need infrastructure but lack expertise. Infrastructure teams become bottlenecks.

### 2. Platform Team Creates Module (3 min)

Show `platform-module/terraform-webserver/`:

**What developers see** (variables.tf):
```hcl
variable "application_name" { }  # What's your app?
variable "environment" { }        # dev/staging/prod?
variable "region_choice" { }      # where?
```

**What platform team handles** (main.tf):
- VPC with networking
- EC2 instance (right-sized by environment)
- Security groups
- Auto-generated SSH keys
- Nginx reverse proxy
- CloudWatch monitoring
- Compliance tags

Published to private registry - versioned, tested, approved.

### 3. Developer Uses Module (4 min)

Show `developer-workflow/deploy-webapp/main.tf`:
```hcl
module "my_server" {
  source  = "app.terraform.io/ORG/webserver/aws"
  version = "1.0.0"
  
  application_name = "customer-portal"
  environment      = "dev"
  region_choice    = "east-us"
}
```

Run deployment:
```bash
./deploy.sh
```

Show result:
- Opens browser to customer portal
- Infrastructure in ~5 minutes
- No AWS or Terraform knowledge needed

### 4. Show Production Scale (2 min)

Developer changes one line:
```hcl
environment = "prod"  # was "dev"
```

Module automatically:
- Uses larger instance (t3.large)
- Applies production hardening
- Enables enhanced monitoring

**Value proposition:**
- ⚡ Infrastructure in minutes, not weeks
- 🎯 Zero infrastructure expertise needed
- 📦 Write once, use everywhere
- 🔒 Security and compliance built-in
- 💰 Cost-effective defaults

## 🎨 Customization

### Module Naming
- Module name: `webserver`
- GitHub repo: `terraform-webserver`
- Registry path: `app.terraform.io/{ORG}/webserver/aws`

Note: The `/aws` suffix is required by Terraform Registry (indicates cloud provider)

### Instance Sizing
Edit `platform-module/terraform-webserver/main.tf`:
```hcl
instance_types = {
  dev     = "t3.small"   # ~$15/month
  staging = "t3.medium"  # ~$30/month
  prod    = "t3.large"   # ~$60/month
}
```

### Regions
Edit `platform-module/terraform-webserver/variables.tf`:
```hcl
region_mappings = {
  "east-us" = "us-east-1"
  "west-us" = "us-west-2"
  "europe"  = "eu-west-1"
}
```

### Branding
Update developer application in `developer-workflow/deploy-webapp/app/server.js`

## 🧹 Cleanup

```bash
cd developer-workflow/deploy-webapp
terraform destroy -auto-approve
rm -f *.pem *.key
```

## 🔧 Troubleshooting

**Module not found in registry**
→ Verify module is published in HCP Terraform (not just GitHub)

**Terraform init fails**
→ Check organization name in main.tf matches your HCP Terraform org

**AWS deployment fails**
→ Verify Doormat credentials are fresh: `doormat login`

**App not accessible**
→ Wait 90 seconds for initialization, then check security group rules

**SSH key issues**
→ Run: `terraform output -raw ssh_private_key > key.pem && chmod 400 key.pem`

## 💡 What Developers Don't Need to Know

The module handles all of this automatically:
- VPCs, subnets, CIDR blocks
- Security groups and rules
- Instance types and sizing
- AMI selection
- State management
- Terraform syntax

Developers only provide:
- Application name
- Environment (dev/staging/prod)
- Region (east-us/west-us/europe)

## 📚 Resources

- Platform module docs: [platform-module/terraform-webserver/README.md](platform-module/terraform-webserver/README.md)
- Developer guide: [developer-workflow/deploy-webapp/README.md](developer-workflow/deploy-webapp/README.md)
- [HCP Terraform Private Registry](https://developer.hashicorp.com/terraform/cloud-docs/registry)
- [No-Code Provisioning](https://developer.hashicorp.com/terraform/cloud-docs/no-code-provisioning)

---

**Ready to demonstrate infrastructure as a product! 🚀**
