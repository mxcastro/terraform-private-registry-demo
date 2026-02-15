# Developer's Infrastructure Configuration
# Using the platform team's no-code web server module

terraform {
  required_version = ">= 1.0"

  # Optional: Use HCP Terraform for remote state
  # cloud {
  #   organization = "YOUR_ORG_NAME"
  #   workspaces {
  #     name = "sarahs-customer-portal-dev"
  #   }
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Use the webserver module from private registry
# This is what the developer creates - simple and clean!
module "my_server" {
  source  = "app.terraform.io/YOUR_ORG/webserver/aws"
  version = "1.0.0"

  # Developer only needs to provide these three values:
  application_name = "customer-portal"
  environment      = "dev"
  region_choice    = "east-us"
}

# Developer wants to see these outputs
output "server_url" {
  description = "URL to access my application"
  value       = module.my_server.http_url
}

output "server_ip" {
  description = "Server IP address"
  value       = module.my_server.server_ip
}

output "ssh_command" {
  description = "How to SSH into my server"
  value       = module.my_server.ssh_command
}

output "deployment_guide" {
  description = "Quick deployment steps"
  value = {
    step_1 = "Save SSH key: terraform output -raw ssh_private_key > customer-portal-dev-key.pem && chmod 400 customer-portal-dev-key.pem"
    step_2 = "Deploy app: scp -i customer-portal-dev-key.pem -r ./app ec2-user@${module.my_server.server_ip}:/home/ec2-user/"
    step_3 = "SSH in: ssh -i customer-portal-dev-key.pem ec2-user@${module.my_server.server_ip}"
    step_4 = "Start app: cd app && npm install && npm start"
    step_5 = "Visit: ${module.my_server.http_url}"
  }
}

output "ssh_private_key" {
  description = "Private key to access the server (keep secure!)"
  value       = module.my_server.ssh_private_key
  sensitive   = true
}
