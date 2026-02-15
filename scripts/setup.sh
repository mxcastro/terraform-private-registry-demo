#!/bin/bash
set -e

echo "=========================================="
echo "Self-Service Infrastructure Demo Setup"
echo "HCP Terraform + MCP Server"
echo "=========================================="
echo ""

# ============================================
# CONFIGURATION - Update these for your demo
# ============================================
GITHUB_USER="${GITHUB_USER:-YOUR_GITHUB_USERNAME}"
ORG_ID="${TFC_ORG:-YOUR_TFC_ORG_ID}"

echo "Configuration:"
echo "  GitHub User: $GITHUB_USER"
echo "  TFC Org: $ORG_ID"
echo ""
echo "To customize, set environment variables:"
echo "  export GITHUB_USER=your-username"
echo "  export TFC_ORG=your-org-id"
echo ""
echo "This script will:"
echo "1. Validate platform team's module"
echo "2. Publish module to GitHub"
echo "3. Guide you through private registry setup"
echo "4. Prepare developer's project"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi
MODULE_NAME="terraform-webserver"
MODULE_DIR="platform-module/terraform-webserver"

# Check prerequisites
echo ""
echo "📋 Checking prerequisites..."
echo ""

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN not set"
    echo "Please set: export GITHUB_TOKEN='your-token'"
    exit 1
fi
echo "  ✅ GITHUB_TOKEN is set"

if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI not installed"
    echo "Please install: brew install gh"
    exit 1
fi
echo "  ✅ GitHub CLI installed"

if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not installed"
    echo "Please install: brew install terraform"
    exit 1
fi
echo "  ✅ Terraform installed"

# Validate module
echo ""
echo "🔍 Step 1: Validating platform module..."
echo "=========================================="
cd "$MODULE_DIR"

terraform fmt -check
echo "  ✅ Format check passed"

terraform init > /dev/null 2>&1
terraform validate
echo "  ✅ Module validation passed"

cd - > /dev/null

# Publish to GitHub
echo ""
echo "📦 Step 2: Publishing module to GitHub..."
echo "=========================================="
cd "$MODULE_DIR"

if [ ! -d ".git" ]; then
    echo "  → Initializing git repository..."
    git init
    git add .
    git commit -m "feat: web server no-code module for Terraform demo"
fi

if gh repo view "$GITHUB_USER/$MODULE_NAME" &> /dev/null; then
    echo "  ℹ️  Repository already exists, pushing updates..."
    git remote add origin "https://github.com/$GITHUB_USER/$MODULE_NAME.git" 2>/dev/null || true
    git push -u origin main || git push -u origin master
else
    echo "  → Creating GitHub repository..."
    gh repo create "$GITHUB_USER/$MODULE_NAME" \
        --public \
        --source=. \
        --remote=origin \
        --description="No-code web server module for HCP Terraform Private Registry demo" \
        --push
fi

echo "  ✅ Module published to GitHub"

# Tag version
if git rev-parse v1.0.0 >/dev/null 2>&1; then
    echo "  ℹ️  Version v1.0.0 already tagged"
else
    echo "  → Tagging version v1.0.0..."
    git tag -a v1.0.0 -m "Version 1.0.0: Initial release"
    git push origin v1.0.0
    echo "  ✅ Version v1.0.0 tagged"
fi

cd - > /dev/null

# Registry setup instructions
echo ""
echo "🏢 Step 3: Register in HCP Terraform Private Registry"
echo "======================================================="
echo ""
echo "🔧 Manual step required:"
echo ""
echo "  1. Open: https://app.terraform.io/app/$ORG_ID/registry/modules/new"
echo "  2. Click 'Connect to GitHub'"
echo "  3. Select repository: $GITHUB_USER/$MODULE_NAME"
echo "  4. Click 'Publish module'"
echo ""
echo "  The module will be available at:"
echo "  app.terraform.io/$ORG_ID/webserver/aws"
echo ""

read -p "Press Enter when module is registered in private registry..."

# Prepare developer project
echo ""
echo "👩‍💻 Step 4: Preparing developer's project..."
echo "==========================================="

DEV_PROJECT="developer-workflow/deploy-webapp"

echo "  → Creating deployment script..."
cat > "$DEV_PROJECT/deploy.sh" <<'DEPLOY_SCRIPT_EOF'
#!/bin/bash
set -e

echo "🚀 Deploying Customer Portal..."

# Check if terraform is initialized
if [ ! -d ".terraform" ]; then
    echo "📦 Initializing Terraform..."
    terraform init
fi

# Apply infrastructure
echo "🏗️  Creating infrastructure..."
terraform apply

# Get server info
SERVER_IP=$(terraform output -raw server_ip)
echo ""
echo "✅ Infrastructure deployed!"
echo "📍 Server IP: $SERVER_IP"

# Save SSH key
echo "🔑 Saving SSH key..."
terraform output -raw ssh_private_key > customer-portal-key.pem
chmod 400 customer-portal-key.pem
echo "  ✅ SSH key saved: customer-portal-key.pem"

# Wait for server to be ready
echo ""
echo "⏳ Waiting 60 seconds for server initialization..."
sleep 60

# Deploy application
echo ""
echo "📦 Deploying application..."
scp -o StrictHostKeyChecking=no -i customer-portal-key.pem -r ./app ec2-user@$SERVER_IP:/home/ec2-user/

echo "📥 Installing dependencies..."
ssh -o StrictHostKeyChecking=no -i customer-portal-key.pem ec2-user@$SERVER_IP "cd app && npm install"

echo "▶️  Starting application..."
ssh -o StrictHostKeyChecking=no -i customer-portal-key.pem ec2-user@$SERVER_IP "cd app && nohup npm start > app.log 2>&1 &"

# Get URL
URL=$(terraform output -raw server_url)

echo ""
echo "=========================================="
echo "✅ Deployment Complete!"
echo "=========================================="
echo ""
echo "🌐 Application URL: $URL"
echo "🔑 SSH Key: customer-portal-key.pem"
echo "📋 View logs: ssh -i customer-portal-key.pem ec2-user@$SERVER_IP 'cat app/app.log'"
echo ""
echo "🎉 Customer portal is now live!"
echo ""
DEPLOY_SCRIPT_EOF

chmod +x "$DEV_PROJECT/deploy.sh"
echo "  ✅ Deployment script created: $DEV_PROJECT/deploy.sh"

# Update main.tf with org
echo "  → Updating main.tf with organization..."
# Create a backup
cp "$DEV_PROJECT/main.tf" "$DEV_PROJECT/main.tf.backup"

# Note: User needs to manually update YOUR_ORG in main.tf
echo "  ⚠️  Note: You need to update '$DEV_PROJECT/main.tf'"
echo "     Replace 'YOUR_ORG' with your actual org name"

# Final summary
echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "📋 What was created:"
echo "  ✅ Platform module validated"
echo "  ✅ Module published to: https://github.com/$GITHUB_USER/$MODULE_NAME"
echo "  ✅ Version v1.0.0 tagged"
echo "  ✅ Ready for private registry registration"
echo "  ✅ Developer project prepared"
echo ""
echo "📝 Next Steps:"
echo ""
echo "1. Complete private registry registration (if not done)"
echo "   URL: https://app.terraform.io/app/$ORG_ID/registry/modules/new"
echo ""
echo "2. Update developer's main.tf:"
echo "   cd $DEV_PROJECT"
echo "   # Edit main.tf - replace YOUR_ORG with actual org name"
echo ""
echo "3. Deploy the application:"
echo "   cd $DEV_PROJECT"
echo "   ./deploy.sh"
echo ""
echo "4.Give your demo! 🎉"
echo ""
echo "📚 Documentation:"
echo "  - NEW_README.md - Complete overview"
echo "  - SCENARIO.md - Detailed scenario"
echo "  - $DEV_PROJECT/README.md - Developer guide"
echo "  - $DEV_PROJECT/DEPLOYMENT.md - Deployment guide"
echo ""
