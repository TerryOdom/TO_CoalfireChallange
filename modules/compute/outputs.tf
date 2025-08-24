# Outputs the ID of the created VPC
output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

# Outputs the ID of the public management subnet
output "management_subnet_id" {
  description = "The ID of the management subnet."
  value       = aws_subnet.management.id
}

# Outputs the ID of the private application subnet
output "application_subnet_id" {
  description = "The ID of the application subnet."
  value       = aws_subnet.application.id
}

# Outputs the ID of the private backend subnet
output "backend_subnet_id" {
  description = "The ID of the backend subnet."
  value       = aws_subnet.backend.id
}
