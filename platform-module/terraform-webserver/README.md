# Web Server - No-Code Module

**Platform Team Module**: This is what gets published to HCP Terraform Private Registry.

## Purpose

Provides developers with a simple, secure web server for hosting applications. Developers answer 3 simple questions - the module handles all AWS complexity.

## Developer Experience

Developers use this module with just 3 inputs:

```hcl
module "my_server" {
  source  = "app.terraform.io/YOUR_ORG/webserver/aws"
  version = "1.0.0"
  
  application_name = "my-app"      # What's your app called?
  environment      = "dev"          # dev, staging, or prod?
  region_choice    = "east-us"     # east-us, west-us, or europe?
}
```

## What This Module Creates

Behind those 3 simple variables, this module provisions:

### Networking
- VPC (10.0.0.0/16)
- Public subnet (10.0.1.0/24)
- Internet gateway
- Route table with internet route

### Compute
- EC2 instance (Amazon Linux 2023)
  - **dev**: t3.small (2 vCPU, 2GB RAM)
  - **staging**: t3.medium (2 vCPU, 4GB RAM)
  - **prod**: t3.large (2 vCPU, 8GB RAM)
- Auto-generated SSH key pair
- Encrypted EBS volume (20GB)

### Security
- Security group with:
  - SSH (port 22)
  - HTTP (port 80)
  - HTTPS (port 443)
  - Application port (3000)
- IMDSv2 enforced
- SSH key authentication only

### Application Support
- Nginx reverse proxy (proxies port 80 to 3000)
- CloudWatch monitoring agent
- Automatic system updates

### Compliance
- All resources tagged with:
  - Application name
  - Environment
  - Cost center
  - Managed by Terraform

## Module Variables

### Required

- **application_name** (string)
  - Description: "What's your application name?"
  - Validation: 2-30 characters, lowercase letters, numbers, or hyphens
  - Example: "customer-portal"

### Optional

- **environment** (string)
  - Description: "What environment is this?"
  - Options: `dev`, `staging`, `prod`
  - Default: `"dev"`

- **region_choice** (string)
  - Description: "Where should this run?"
  - Options: `east-us`, `west-us`, `europe`
  - Default: `"east-us"`
  - Maps to: us-east-1, us-west-2, eu-west-1

## Module Outputs

- **server_ip** - Public IP address
- **server_dns** - Public DNS name
- **http_url** - HTTP URL to access the application
- **ssh_command** - Command to SSH into the server
- **ssh_private_key** - Private SSH key (sensitive)
- **instance_id** - EC2 instance ID
- **vpc_id** - VPC ID
- **subnet_id** - Subnet ID
- **security_group_id** - Security group ID
- **deployment_info** - Summary object with all key information

## Publishing to Private Registry

### Step 1: Publish to GitHub

```bash
# In this directory
git init
git add .
git commit -m "feat: AWS web server no-code module"

# Create GitHub repo
gh repo create YOUR_USER/terraform-webserver --public --source=. --push

# Tag version
git tag v1.0.0
git push origin v1.0.0
```

### Step 2: Register in HCP Terraform

1. Go to: **https://app.terraform.io/app/YOUR_ORG/registry/modules/new**
2. Click "Connect to GitHub"
3. Select: `YOUR_USER/terraform-webserver`
4. Click "Publish module"

Module will be available at: `app.terraform.io/YOUR_ORG/webserver/aws`

## Testing the Module

```bash
# Validate
terraform init
terraform validate

# Format
terraform fmt -check

# Test plan
terraform plan -var="application_name=test"
```

## Cost Estimate

| Environment | Instance Type | Monthly Cost |
|-------------|---------------|--------------|
| dev | t3.small | ~$15 |
| staging | t3.medium | ~$30 |
| prod | t3.large | ~$60 |

## Security Features

- VPC isolation
- Minimal security group rules
- SSH key authentication only
- No password authentication
- Encrypted EBS volumes
- IMDSv2 enforced
- CloudWatch logging enabled
- Automatic security updates
- Proper resource tagging for compliance

## Maintenance

- Update base AMI quarterly
- Review security groups monthly
- Monitor CloudWatch metrics
- Update module version tags
- Test changes in dev environment first

## Version History

- **v1.0.0** - Initial release
  - VPC + EC2 infrastructure
  - 3 developer-friendly variables
  - Nginx reverse proxy
  - CloudWatch monitoring
  - Cloud-agnostic naming for developer simplicity

## Support

For issues or feature requests:
- Check CloudWatch logs
- Review Terraform state
- Verify AWS credentials
- Check security group rules

---

**This module enables developers to self-serve infrastructure in minutes! 🚀**
