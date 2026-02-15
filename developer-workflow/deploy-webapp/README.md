# Developer Workflow: Deploy Web Application

This is an example of how developers use platform team's modules.

## 🎯 The Goal

A developer built a Node.js customer portal and needs to deploy it to AWS but doesn't know Terraform or AWS infrastructure.

## ✨ The Solution

The developer creates a super simple `main.tf` that uses the platform team's `webserver` module from the private registry.

## 📝 Developer's Infrastructure Code

```hcl
module "my_server" {
  source  = "app.terraform.io/YOUR_ORG/webserver/aws"
  version = "1.0.0"
  
  application_name = "customer-portal"
  environment      = "dev"
  region_choice    = "east-us"
}
```

**That's all she needs!** Three simple variables:
- `application_name` - "What's your app called?"
- `environment` - "dev, staging, or prod?"
- `region_choice` - "east-us, west-us, or europe?"

## 🚀 How to Deploy

### One-Command Deployment

```bash
./deploy.sh
```

This will:
1. Initialize Terraform
2. Create all infrastructure (VPC, EC2, security groups, etc.)
3. Deploy the Node.js application
4. Start the web server

## 🌐 Access Your Application

```bash
# Get the URL
terraform output server_url

# Open in browser
```

You'll see the customer portal!

## 📦 What's Included

```
deploy-webapp/
├── main.tf              # Uses platform module (3 variables!)
├── app/                 # Developer's Node.js application
│   ├── server.js        # Application code
│   └── package.json     # Dependencies
└── deploy.sh            # One-command deployment
```

## ✅ What the Platform Module Handles

Behind those 3 simple variables, the module creates:
- VPC with public subnet
- Internet gateway and route tables
- Security groups (HTTP, HTTPS, SSH, app port)
- EC2 instance (right-sized for environment)
- SSH key pair (auto-generated)
- Nginx reverse proxy
- CloudWatch monitoring
- Cost allocation tags

## 🔄 Moving to Production

Change one line:

```hcl
environment = "prod"  # was "dev"
```

The module automatically uses larger instance and production settings!

## 🧹 Cleanup

```bash
terraform destroy
```

---

**Infrastructure in 5 minutes with 3 simple variables! 🚀**
