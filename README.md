# Infrastructure Deployment with AI Assistance
## A Developer's Guide to Self-Service Infrastructure

> 🎯 **This guide is for developers with zero infrastructure knowledge who need to deploy their applications to the cloud using AI-powered assistance.**

## What is This?

You're a developer. You've built an application (in the `app/` folder), and now you need to **deploy it to the cloud**. 

But there's good news: **Your platform team has already done the hard work.** They've created a reusable infrastructure template (called a "module") that's available in your company's private module registry. 

**You don't need to know:**
- What AWS is or how it works
- What Terraform does
- How to configure servers, networks, or security
- Anything about infrastructure

**What you will do:**
- Use AI/Agent assistance to discover available infrastructure options
- Let the AI guide you through selecting the right module
- Provide simple information (app name, environment type)
- Deploy your server infrastructure
- Get the information needed for your CI/CD pipeline to deploy your actual application

**Time to complete:** 15-20 minutes

---

# 📋 Prerequisites

Before starting, make sure you have:

## 1. Development Environment
- **VS Code** installed with Copilot or similar AI assistant
- **Terraform MCP Server** extension or plugin installed
- **Terminal** access

## 2. Credentials (provided by your Platform Team)

Your platform team should have given you:

✅ **HCP Terraform Organization**: `org-xxxxxxxxxxxxx`  
✅ **HCP Terraform Token**: `xxxxx.atlasv1.xxxxx`  
✅ **AWS Credentials**: Already configured for you in your workspace  
✅ **Workspace Name**: The workspace where your infrastructure will be deployed

> 💡 **Important:** Your platform team has already configured your workspace in HCP Terraform. You just need to connect to it.

## 3. Files You Should Have

In this repository:
```
developer-workflow/
└── deploy-webapp/
    ├── app/               # Your application code (Node.js)
    └── main.tf           # Infrastructure config (you'll create this)
```

---

# 🚀 Part 1: Setup MCP Server in VS Code

The **Terraform MCP Server** is an AI-powered tool that helps you discover and use infrastructure modules without knowing Terraform.

## Step 1: Configure MCP Server

**Create or edit your MCP configuration file:**

**For VS Code (settings.json):**
```json
{
  "mcp.servers": {
    "terraform": {
      "command": "terraform-mcp-server",
      "args": [],
      "env": {
        "TFE_TOKEN": "your-hcp-terraform-token-here",
        "TFE_ADDRESS": "https://app.terraform.io",
        "TF_CLOUD_ORGANIZATION": "your-org-id-here"
      }
    }
  }
}
```

**Replace these values:**
- `your-hcp-terraform-token-here` → Token from your platform team
- `your-org-id-here` → Organization ID from your platform team (e.g., `org-xxxxxxxxxxxxx`)

## Step 2: Verify MCP Server Connection

Open VS Code terminal and ask your AI assistant:

```
🤖 "Check if the Terraform MCP Server is connected and can access 
my HCP Terraform organization. Show me what workspaces are available."
```

**Expected response:**
- MCP Server status: Connected ✅
- Organization: Your org name
- Available workspaces: List of workspaces
- Private modules: Available modules in registry

---

# 👨‍💻 Part 2: Discover Available Infrastructure

Now let's use AI to discover what infrastructure options are available for you.

## Step 3: Ask AI to Analyze Available Modules

Navigate to your working directory:
```bash
cd developer-workflow/deploy-webapp
```

**Ask your AI assistant:**
```
🤖 "I need to deploy a web application to the cloud. Using the Terraform MCP Server, 
show me what infrastructure modules are available in my organization's private registry 
that can help me deploy a web server. What are my options?"
```

**What the AI should tell you:**

The AI will use the MCP Server to query your private registry and find modules like:
- **Module name**: `webserver`
- **Provider**: AWS
- **What it does**: Creates a complete web server with networking, security, and compute
- **Full path**: `app.terraform.io/YOUR_ORG/webserver/aws`

## Step 4: Understand What the Module Provides

**Ask your AI assistant:**
```
🤖 "Explain what the 'webserver' module does in simple terms. 
What infrastructure will it create for me? What information do I need to provide?"
```

**Expected AI response:**

The module will create:
- ✅ A virtual private network (isolated network for your app)
- ✅ A server (computer in the cloud) to run your application
- ✅ Security settings (firewall rules to protect your server)
- ✅ SSH access (way to connect to your server)
- ✅ Web server (Nginx configured to serve your app)

What you need to provide:
- **application_name**: A name for your app (e.g., "customer-portal")
- **environment**: Is this for development, staging, or production? (`dev`, `staging`, `prod`)
- **region_choice**: Where in the world should this run? (`east-us`, `west-us`, `europe`)

> 💡 **That's it!** Just 3 simple pieces of information.

---

# 🏗️ Part 3: Let AI Generate Your Infrastructure Configuration

Instead of writing code manually, you'll answer a few simple questions and let the AI/MCP Server create the configuration file for you.

## Step 5: Answer Questions and Let AI Generate Configuration

Navigate to your working directory:
```bash
cd developer-workflow/deploy-webapp
```

**Ask your AI assistant:**
```
🤖 "I need to deploy a web server for my application using the webserver module 
from my private registry. Using the Terraform MCP Server, help me generate the 
configuration automatically. Ask me any questions you need."
```

**The AI will ask you questions like:**

1. **"What's your application name?"**
   - Answer: `customer-portal` (or your app name)

2. **"Which environment? (dev, staging, or prod)"**
   - Answer: `dev` (start with development)

3. **"Which region? (east-us, west-us, or europe)"**
   - Answer: `east-us` (or your preferred region)

4. **"What's your HCP Terraform workspace name?"**
   - Answer: The workspace name your platform team gave you

**What happens next:**

The AI/MCP Server will:
- ✅ Use your MCP configuration (organization, token) automatically
- ✅ Find the webserver module in your private registry
- ✅ Generate a `main.tf` file with all the correct settings
- ✅ Include proper workspace configuration
- ✅ Add outputs for deployment information

**The AI generates this file automatically:**

```hcl
# Generated by AI/MCP Server
terraform {
  required_version = ">= 1.0"
  
  cloud {
    organization = "YOUR_ORG_ID"  # From your MCP config
    workspaces {
      name = "your-workspace-name"  # From your answer
    }
  }
}

module "my_server" {
  source  = "app.terraform.io/YOUR_ORG_ID/webserver/aws"
  version = "1.0.0"
  
  application_name = "customer-portal"  # From your answer
  environment      = "dev"              # From your answer
  region_choice    = "east-us"          # From your answer
}

output "server_ip" {
  value = module.my_server.server_ip
}

output "server_url" {
  value = module.my_server.http_url
}

output "ssh_command" {
  value = module.my_server.ssh_command
}

output "deployment_instructions" {
  value = module.my_server.deployment_info
}
```

> 💡 **You didn't write any code!** The AI generated it based on your answers.

## Step 6: Confirm the Generated Configuration

**Ask your AI assistant:**
```
🤖 "Show me the main.tf file you created and explain what it does in simple terms."
```

**Expected AI explanation:**

- **terraform block**: Connects to your HCP Terraform workspace (so your team can see what you deployed)
- **module block**: Uses the webserver module with your specific settings
- **outputs**: Defines what information you'll get after deployment (IP address, URL, SSH command)

---

# 🚀 Part 4: Deploy Your Infrastructure

Now for the exciting part - actually creating your infrastructure!

## Step 7: Let AI Initialize and Deploy

Once the AI has generated your `main.tf` file, it can handle the entire deployment process.

**Ask your AI assistant:**
```
🤖 "I'm ready to deploy this infrastructure. Walk me through what will happen 
and deploy it for me step by step. Explain each step in simple terms."
```

The AI will guide you through three phases: **Initialize**, **Preview**, and **Deploy**.

---

### Phase 1: Initialize (Setup)

## Step 8: AI Initializes Terraform

### Phase 1: Initialize (Setup)

## Step 8: AI Initializes Terraform

> 📚 **What is initialize?** Think of it like "npm install" - it downloads the module and prepares everything.

**The AI will explain:**
```
"I'm going to initialize Terraform now. This will download the webserver module 
from your private registry and connect to your HCP Terraform workspace. You'll 
see some messages about what's being set up."
```

**The AI runs:**
```bash
terraform init
```

**What you'll see:**
```
Initializing Terraform Cloud...
Initializing modules...
- my_server in app.terraform.io/YOUR_ORG/webserver/aws

Terraform has been successfully initialized!
```

✅ **Success indicator**: "successfully initialized"

---

### Phase 2: Preview Changes

## Step 9: AI Shows Preview of Infrastructure

> 📚 **What is plan?** It's like a "preview" - shows you what will be created before actually doing it.

**The AI will explain:**
```
"Let me show you what infrastructure will be created. This is a preview - 
nothing is actually deployed yet. I'll explain what each resource is."
```

**The AI runs:**
```bash
terraform plan
```

**The AI explains the output:**

"Your infrastructure will include:
- **aws_vpc**: Your own private network in the cloud
- **aws_subnet**: A section of that network
- **aws_internet_gateway**: Connection to the internet
- **aws_route_table**: Rules for network traffic
- **aws_security_group**: Firewall protecting your server
- **aws_instance**: Your actual server (a computer in AWS)
- **tls_private_key**: SSH key to access your server

At the bottom, you'll see:
```
Plan: 8 to add, 0 to change, 0 to destroy.
```

This means I'll create 8 new resources for you."

---

### Phase 3: Deploy

## Step 10: AI Deploys the Infrastructure

> 📚 **What is apply?** This is the "go" button - it actually creates your infrastructure in the cloud.

**The AI asks for confirmation:**
```
"I'm ready to create your infrastructure. This will:
- Create real resources in AWS
- Take about 2-3 minutes
- Cost a small amount (about $0.02/hour for dev environment)

Should I proceed?"
```

**You answer:** "Yes" or "Go ahead"

**The AI runs:**
```bash
terraform apply
```

**The AI keeps you updated:**
```
"Creating your network... ✓
Creating security rules... ✓
Launching your server... (this takes 1-2 minutes)
Still working... your server is starting up...
Almost done... configuring web server...
Done! ✓"
```

**What you'll see in the terminal:**
```
module.my_server.aws_vpc.main: Creating...
module.my_server.aws_vpc.main: Creation complete after 2s
module.my_server.aws_subnet.public: Creating...
...
module.my_server.aws_instance.web: Still creating... [10s elapsed]
module.my_server.aws_instance.web: Still creating... [20s elapsed]
...
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.
```

⏱️ **Wait time**: 2-3 minutes

✅ **Success indicator**: "Apply complete!"

---

# 📊 Part 5: Get Your Deployment Information

Your infrastructure is now live! Let's get the information you need.

## Step 11: AI Shows Your Server Information

**Ask your AI assistant:**
```
🤖 "My infrastructure is deployed! Show me all the information about my server. 
What can I do with it now?"
```

**The AI will run:**
```bash
terraform output
```

**And explain the outputs:**

```
server_ip = "54.123.45.67"
  → This is your server's public IP address

server_url = "http://54.123.45.67"
  → Open this URL in your browser to access your server

ssh_command = "ssh -i customer-portal-dev-key.pem ec2-user@54.123.45.67"
  → Use this command to connect to your server via SSH

deployment_instructions = {
  "app_port" = "3000"
  "server_ip" = "54.123.45.67"
  "ssh_user" = "ec2-user"
  "web_root" = "/var/www/html"
}
  → Information your CI/CD pipeline needs
```

## Step 12: Test Your Server

**Ask your AI assistant:**
```
🤖 "Can I test if my server is running right now? Show me how."
```

**The AI will guide you:**

"Yes! Open your browser and go to the server URL. Let me open it for you..."

**Or copy the URL manually:**
```bash
# The AI shows you the URL
echo "Your server is at: $(terraform output -raw server_url)"
```

**What you'll see:**
A welcome page from Nginx (the web server software that's pre-installed).

> 💡 The server infrastructure is ready - it just doesn't have your application deployed yet!

---

# 🔄 Part 6: Prepare for Application Deployment

You now have infrastructure, but your actual application (the code in `app/`) isn't deployed yet.

## Step 13: Get CI/CD Deployment Information

**Ask your AI assistant:**
```
🤖 "I have a CI/CD pipeline (GitHub Actions / GitLab CI / Jenkins) that will 
deploy my application code. What information from this infrastructure does my 
pipeline need? Create a summary for me."
```

**The AI will generate a deployment guide:**

```yaml
# CI/CD Pipeline Configuration
# Save this for your deployment pipeline

deployment:
  type: aws_ec2
  server_ip: "54.123.45.67"      # Server address
  ssh_user: "ec2-user"            # User to login as
  app_port: 3000                  # Your app should listen here
  web_server: "nginx"             # Pre-installed and configured
  
  # Nginx is already configured to:
  # - Listen on port 80 (external)
  # - Proxy requests to port 3000 (your app)
  
deployment_steps:
  1. "Copy application files to: /home/ec2-user/app/"
  2. "Your app must listen on port 3000"
  3. "Nginx will automatically proxy traffic to your app"
  4. "Access your app at: http://54.123.45.67"
```

## Step 14: Get SSH Key for CI/CD

**Ask your AI assistant:**
```
🤖 "My CI/CD pipeline needs an SSH key to deploy. How do I get 
the private key that was generated?"
```

**The AI will run:**
```bash
# Extract the private key
terraform output -raw ssh_private_key > deployment-key.pem

# Set correct permissions
chmod 400 deployment-key.pem

echo "SSH key saved to deployment-key.pem"
```

> ⚠️ **Security note**: The AI will remind you: "Add this key to your CI/CD pipeline secrets. Never commit it to git!"

## Step 15: Save All Deployment Information

**Ask your AI assistant:**
```
🤖 "Create a complete deployment information file that I can share 
with my DevOps team or use in my CI/CD configuration."
```

**The AI will generate a comprehensive file:**

```bash
cat > deployment-info.txt << EOF
# Server Deployment Information
# Generated: $(date)
# Application: customer-portal
# Environment: dev

=== SERVER ACCESS ===
Server IP: $(terraform output -raw server_ip)
Server URL: $(terraform output -raw server_url)
SSH User: ec2-user

=== APPLICATION CONFIGURATION ===
Port: Your app must listen on port 3000
Web Server: Nginx (pre-configured)
Proxy: External port 80 → Internal port 3000

=== SSH ACCESS ===
$(terraform output -raw ssh_command)

=== CI/CD INTEGRATION ===
1. Add deployment-key.pem to your pipeline secrets
2. Deploy app files to: /home/ec2-user/app/
3. Ensure app listens on port 3000
4. Nginx will automatically proxy traffic

=== DEPLOYMENT COMMANDS ===
# Copy files to server
scp -i deployment-key.pem -r ./app ec2-user@$(terraform output -raw server_ip):/home/ec2-user/

# SSH into server
ssh -i deployment-key.pem ec2-user@$(terraform output -raw server_ip)

# Restart your app (example for Node.js)
ssh -i deployment-key.pem ec2-user@$(terraform output -raw server_ip) 'cd app && npm install && pm2 restart all'

EOF

cat deployment-info.txt
```

**The AI explains:** "I've created deployment-info.txt with everything your DevOps team or CI/CD pipeline needs!"

---

# 🎓 Understanding What Just Happened

Let's break down what the AI did for you:

## The Power of AI + Infrastructure as Code

**What you did:**
1. ✅ Answered 4 simple questions (app name, environment, region, workspace)
2. ✅ Confirmed deployment
3. ✅ Got your server information

**What the AI/MCP Server did for you:**
1. 🤖 Discovered the webserver module in your private registry
2. 🤖 Generated the entire main.tf configuration file
3. 🤖 Initialized Terraform and downloaded dependencies
4. 🤖 Showed you a preview of infrastructure
5. 🤖 Deployed 8 cloud resources for you
6. 🤖 Extracted deployment information
7. 🤖 Created documentation for your CI/CD pipeline

**Total time:** 15-20 minutes ⏱️

**Code you wrote:** 0 lines ✨

## What the Platform Team Provided

Your platform team created the `webserver` module that:
- ✅ Encapsulates 300+ lines of infrastructure code
- ✅ Follows security and compliance best practices
- ✅ Handles all AWS complexity (networking, security, compute)
- ✅ Provides a simple 3-variable interface
- ✅ Is version-controlled and centrally maintained
- ✅ Works the same way for every developer

**You leverage their expertise without needing it yourself!**

## The Role of Terraform MCP Server

The MCP (Model Context Protocol) Server integration:
- 🤖 **Discovered** available modules in your private registry
- 🤖 **Analyzed** module requirements and capabilities
- 🤖 **Generated** correct Terraform configuration automatically
- 🤖 **Orchestrated** the entire deployment workflow
- 🤖 **Explained** technical concepts in plain English
- 🤖 **Extracted** deployment information for CI/CD
- 🤖 **Guided** you through each step conversationally

**You interacted with infrastructure using natural language, not code!**
- 🤖 **Guided** you through each step conversationally

**You interacted with infrastructure using natural language, not code!**

## Without AI vs With AI

### Traditional Way (Without AI):
```
1. Read Terraform documentation (hours)
2. Learn HCL syntax
3. Understand module registry
4. Write main.tf manually
5. Debug syntax errors
6. Figure out workspace configuration
7. Learn terraform commands
8. Parse output manually

Time: Days to weeks
Knowledge needed: High
```

### AI-Powered Way (This Demo):
```
1. Answer simple questions
2. Let AI generate everything
3. Confirm deployment
4. Get results

Time: 15-20 minutes
Knowledge needed: Zero
```

---

# 🧹 When You're Done: Cleanup

When you're finished testing or want to tear down the infrastructure:

## Step 16: Destroy Infrastructure with AI

**Ask your AI assistant:**
```
🤖 "I'm done with this server and want to delete all the infrastructure 
to avoid costs. How do I safely destroy everything? Show me what will 
be deleted first."
```

**The AI will:**

1. **Show you what will be destroyed:**
   ```bash
   terraform plan -destroy
   ```

2. **Explain what's being deleted:**
   ```
   "I'll delete:
   - Your EC2 server
   - The private network (VPC)
   - Security rules
   - SSH keys
   - Internet gateway
   - All 8 resources we created
   
   Your code and configuration will remain - you can recreate 
   this infrastructure anytime by running 'terraform apply' again."
   ```

3. **Ask for confirmation:**
   ```
   "Should I proceed with destroying these resources?"
   ```

4. **Execute the destruction:**
   ```bash
   terraform destroy
   ```

**What stays:**
- ✅ Your application code (in `app/` folder)
- ✅ Your main.tf configuration file
- ✅ Your Terraform state (in HCP Terraform workspace)
- ✅ The webserver module (in private registry)

**What gets deleted:**
- ❌ All AWS infrastructure
- ❌ The running server
- ❌ Network configuration
- ❌ SSH keys

> 💡 To recreate everything, just ask the AI: "Deploy my infrastructure again" and it will run `terraform apply`!

---

# 🎯 What About Deploying to Production?

When you're ready for production, it's just as easy!

## Step 17: Deploy to Production

**Ask your AI assistant:**
```
🤖 "I want to deploy this application to production. What changes, 
and how do I do it safely?"
```

**The AI will explain:**

"For production, you'll need:
1. A dedicated production workspace (ask your platform team)
2. Change one setting: environment = 'prod'
3. Consider a different region if needed

Let me help you create a production configuration..."

**The AI will generate a new main.tf or help you modify:**

```hcl
module "my_server" {
  source  = "app.terraform.io/YOUR_ORG_ID/webserver/aws"
  version = "1.0.0"
  
  application_name = "customer-portal"
  environment      = "prod"      # Changed from "dev"
  region_choice    = "east-us"   # You can change this too
}
```

**What changes automatically when environment = "prod":**
- 🔧 Larger server size (t3.large instead of t3.small)
- 🔧 Production-grade instance settings
- 🔧 Enhanced monitoring configuration
- 🔧 Backup policies enabled
- 🔧 Higher resource limits

**The AI reminds you:**
```
"Production deployments should be reviewed by your team. Make sure you:
- Use a separate production workspace
- Have appropriate access controls
- Follow your company's change management process
- Have a rollback plan"
```

**Best Practice**: Ask the AI:
```
🤖 "What's the difference between dev, staging, and prod environments 
for this module? Show me what changes in each."
```

---

# 🔧 Troubleshooting with AI

If anything goes wrong, ask your AI assistant for help!

## Common Issues

**"Terraform not found"**
```
🤖 "I get 'terraform: command not found'. How do I install Terraform?"
```

**"Error: Invalid credentials"**
```
🤖 "I get AWS credentials error. How do I check my credentials are correct?"
```

**"Module not found"**
```
🤖 "Terraform can't find the webserver module. How do I verify my HCP Terraform token and organization?"
```

**"Permission denied"**
```
🤖 "I get permission denied errors. Do I have the right permissions?"
```

**"Resource already exists"**
```
🤖 "Terraform says a resource already exists. What does this mean and how do I fix it?"
```

## General Troubleshooting Approach

**Always ask your AI assistant:**
1. "What does this error mean in simple terms?"
2. "What are common causes of this error?"
3. "How can I fix it step by step?"
4. "How can I verify the fix worked?"

---

# 📚 Key Concepts (Explained Simply)

## Terraform
Think of it like: **Docker Compose for infrastructure**
- Docker Compose defines containers → Terraform defines cloud resources
- docker-compose.yml file → main.tf file
- docker-compose up → terraform apply
- docker-compose down → terraform destroy

## HCP Terraform (Terraform Cloud)
Think of it like: **GitHub for infrastructure**
- Stores your infrastructure state (like git stores code)
- Runs Terraform commands remotely (like CI/CD)
- Manages teams and permissions
- Tracks changes and history

## Module
Think of it like: **npm package or Docker image**
- Reusable infrastructure template
- Published to a registry
- Versioned (v1.0.0, v2.0.0)
- Abstracts complexity

## Workspace
Think of it like: **Git branch or environment**
- Separate state for different environments
- dev workspace, staging workspace, prod workspace
- Isolates infrastructure

## Apply
Think of it like: **git push**
- Actually creates/updates infrastructure
- Changes real resources in the cloud
- Requires confirmation (`yes`)

## Plan
Think of it like: **git diff**
- Shows what will change
- Doesn't modify anything
- Safe to run anytime

---

# 🎉 Congratulations!

You've successfully:
- ✅ Deployed cloud infrastructure **without writing any code**
- ✅ Used AI to automatically generate Terraform configuration
- ✅ Leveraged MCP Server to discover and use private registry modules
- ✅ Had the AI orchestrate the entire deployment workflow
- ✅ Got deployment information for your CI/CD pipeline
- ✅ Learned infrastructure concepts through AI explanations

**What you actually did:**
- Answered 4 simple questions
- Confirmed deployment
- Got a working server

**What the AI did:**
- Generated 60+ lines of Terraform code
- Deployed 8 cloud resources
- Configured networking and security
- Set up SSH access
- Created deployment documentation

**Time spent:** 15-20 minutes
**Code written:** 0 lines
**Infrastructure deployed:** Production-ready web server

**You deployed enterprise-grade infrastructure without becoming an infrastructure expert!**

## Next Steps

1. **Integrate with CI/CD**: Use the deployment info to configure your pipeline
2. **Deploy your app**: Let your CI/CD pipeline deploy the actual application
3. **Monitor**: Ask your platform team about monitoring and logging
4. **Scale**: When ready, deploy to staging and production

## Getting Help

- Ask your platform team about available modules
- Use AI assistant for any Terraform questions
- Check HCP Terraform docs: https://developer.hashicorp.com/terraform/cloud-docs
- Experiment in `dev` environment (safe to break!)

**Remember: You don't need to become an infrastructure expert. The platform team and AI tools are here to help you focus on building great applications!** 🚀
