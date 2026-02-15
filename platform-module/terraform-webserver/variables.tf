variable "application_name" {
  description = "What's your application name? (e.g., 'customer-api', 'web-portal')"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,30}$", var.application_name))
    error_message = "Application name must be 2-30 characters, lowercase letters, numbers, or hyphens only."
  }
}

variable "environment" {
  description = "What environment is this for?"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be: dev, staging, or prod."
  }
}

variable "region_choice" {
  description = "Where should this run?"
  type        = string
  default     = "east-us"

  validation {
    condition     = contains(["east-us", "west-us", "europe"], var.region_choice)
    error_message = "Region must be: east-us, west-us, or europe."
  }
}

# Internal mappings (hidden from developers)
locals {
  region_map = {
    "east-us" = "us-east-1"
    "west-us" = "us-west-2"
    "europe"  = "eu-west-1"
  }

  instance_size_map = {
    "dev"     = "t3.small"
    "staging" = "t3.medium"
    "prod"    = "t3.large"
  }

  selected_region        = local.region_map[var.region_choice]
  selected_instance_type = local.instance_size_map[var.environment]

  # Standard tags applied to all resources
  common_tags = {
    Application = var.application_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "webserver"
    CostCenter  = "Engineering"
  }
}
