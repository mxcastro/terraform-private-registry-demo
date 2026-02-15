output "server_ip" {
  description = "Public IP address of your web server"
  value       = aws_instance.web_server.public_ip
}

output "server_dns" {
  description = "Public DNS name of your web server"
  value       = aws_instance.web_server.public_dns
}

output "http_url" {
  description = "HTTP URL to access your application"
  value       = "http://${aws_instance.web_server.public_ip}"
}

output "ssh_command" {
  description = "Command to SSH into your server"
  value       = "ssh -i ${var.application_name}-${var.environment}-key.pem ec2-user@${aws_instance.web_server.public_ip}"
}

output "ssh_private_key" {
  description = "Private SSH key (save this securely!)"
  value       = tls_private_key.web_server.private_key_pem
  sensitive   = true
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web_server.id
}

output "vpc_id" {
  description = "VPC ID (for advanced configurations)"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Subnet ID (for advanced configurations)"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Security group ID (for advanced configurations)"
  value       = aws_security_group.web_server.id
}

output "deployment_info" {
  description = "Quick deployment guide"
  value = {
    application  = var.application_name
    environment  = var.environment
    region       = local.selected_region
    instance_type = local.selected_instance_type
    server_url   = "http://${aws_instance.web_server.public_ip}"
    deploy_path  = "/home/ec2-user/app"
    app_port     = "3000"
  }
}
